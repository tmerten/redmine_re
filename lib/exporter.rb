require 'pdfkit'

class Exporter
  include ApplicationHelper
  include ActionView::Helpers::TranslationHelper
  
  def initialize(root_node, base_url)
    @root_node = root_node
    
    # init chapter numbering counters  
    @chp1 = 1
    @chp2 = 1
    @chp3 = 1
    @chp4 = 1
    @chp5 = 1
    
    @last_depth = 0
    
    @toc = false # put to configuration later
    @toc_html = ''
    
    @base_url = base_url
  end
  
  def get_root_node
    @root_node
  end
  
  def flatify()
    flat_tree = []
    flat_tree = get_flatten_tree(self.get_root_node(), 10, flat_tree, -1)
    flat_tree
  end
  
  def get_flatten_tree(re_artifact_properties, depth, flat_tree_list, depth_counter)
    
    artifact_type = re_artifact_properties.artifact_type.to_s.underscore
    artifact_name = re_artifact_properties.name.to_s
    artifact_id = re_artifact_properties.id.to_s
    has_children = !re_artifact_properties.children.empty?

    # Push item to flat list
    item = {}
    item['id'] = artifact_id.to_s
    item['type'] = artifact_type
    item['name'] = artifact_name
    item['descr'] = re_artifact_properties.description.to_s
    item['depth'] = depth_counter # Depth counter for chapter numbering 
    item['author'] = re_artifact_properties.author
    item['updated'] = re_artifact_properties.updated_at.to_s   
    item['url'] = @base_url.sub("XX", artifact_id)
    
    flat_tree_list << item
       
    if has_children
      flat_tree_list == get_children_flat(re_artifact_properties, depth-1, flat_tree_list,depth_counter+1)
    end

    flat_tree_list  
  end
  
  def get_children_flat(re_artifact_properties, depth, flat_tree_list, depth_counter)
    
    for child in re_artifact_properties.children
      #logger.debug child.to_s     
      if (depth > 0)
          flat_tree_list = get_flatten_tree(child, depth, flat_tree_list, depth_counter)
      end
    end
    flat_tree_list
  end
  
  def get_pdf
    flat_tree = self.flatify()
      
    html = ''
    flat_tree.each do |item|
      
      if item['depth'] < @last_depth
        # we jump up in the list
        self.increase_numbering(item['depth'])
        self.reset_numbering_below(item['depth'])
      elsif item['depth'] == @last_depth
        self.increase_numbering(item['depth'])
      end
      
      html = html + self.format_artifact(item)
      @last_depth = item['depth']
      
    end
    
    if @toc
      html = @toc_html + html
    end
    
    pdf = PDFKit.new(html, :page_size => 'Letter') 
    pdf.stylesheets << Rails.root + 'plugins/redmine_re/assets/export_templates/export.css'
    pdf.to_pdf    
  end
  
  def format_artifact(artifact)

    tpl_fn = artifact['type'] + '.tpl'
    
    begin
      tpl = File.read(Rails.root + "plugins/redmine_re/assets/export_templates/" + tpl_fn)
    rescue
      # When template was not found force to use generic template
      artifact['type'] = 'generic'
    end
    
    # Calculate hX tag depending on depth
    artifact['depth'] < 2 ? hx = (artifact['depth'] + 2).to_s : hx = "4"  
    
    case artifact['type']
      
    when 'project'
      tpl = tpl.sub('{{HEADING}}', artifact['name'])
      tpl = tpl.sub('{{DESCRIPTION}}', textilizable(artifact['descr']))    
    when 're_section'
      tpl = tpl.sub('{{HEADING}}', self.get_chapter_heading(artifact['depth'], artifact['name']))
      tpl = tpl.gsub('{{HX}}',hx) # set <hX> tags accordingly to depth
      
      if @toc
        @toc_html = @toc_html + tpl
      end
      
    when 're_requirement'
      #tpl = tpl.sub('{{HEADING}}', self.get_chapter_heading(artifact['depth'], artifact['name']))    
      
      tpl = tpl.sub('{{HEADING}}', "[Requirement #"+ artifact['id']+"] "+artifact['name'])    
      tpl = tpl.gsub('{{HX}}', hx) # set <hX> tags accordingly to depth
      tpl = tpl.sub('{{DESCRIPTION}}', artifact['descr'])    
      tpl = tpl.sub('{{REQ_URL}}', artifact['url'])
     
    when 're_feature'
      json = ActiveSupport::JSON.decode(artifact['descr'])
      
      tpl = tpl.sub('{{HEADING}}', self.get_chapter_heading(artifact['depth'], artifact['name']))
      tpl = tpl.gsub('{{HX}}', hx) # set <hX> tags accordingly to depth
      tpl = tpl.sub('{{NAME}}', artifact['name'])
      
      tpl = tpl.sub('{{OUTLINE}}', json['description'].join('<br/>'))
      
      if json['background'].length > 0
        
        bg_tpl = File.read(Rails.root + "plugins/redmine_re/assets/export_templates/re_feature_background.tpl")
        
        steps = ''
        json['background']['steps'].each do |step|
          chunks = step.split('#')
          steps = steps + '<strong>'+chunks[0]+': </strong>' + chunks[1] + '<br/>'
        end
        
        bg_tpl = bg_tpl.sub('{{STEPS}}', steps)
        
        tpl = tpl.sub('{{BACKGROUND}}', bg_tpl)
      else
        tpl = tpl.sub('{{BACKGROUND}}', '')
      end
      
      scenarios_html = ''
      
      json['scenarios'].each do |scenario|
    
        scn_tpl = File.read(Rails.root + "plugins/redmine_re/assets/export_templates/re_feature_scenario.tpl")
        
        scn_tpl = scn_tpl.sub('{{NAME}}', scenario['name'])
        
        steps = ''
        scenario['steps'].each do |step|
          chunks = step.split('#')
          steps = steps + '<strong>'+chunks[0]+': </strong>' + chunks[1] + '<br/>'
        end
        
        scn_tpl = scn_tpl.sub('{{STEPS}}', steps)
        
        scenarios_html = scenarios_html + scn_tpl  
      end
      
      tpl = tpl.sub('{{SCENARIOS}}', scenarios_html)
    
    else
      
      # Override template and load generic template
      tpl = File.read(Rails.root + "plugins/redmine_re/assets/export_templates/re_generic.tpl")
      
      chunks = artifact['type'].sub('re_','').split('_')
      
      type_pretty = ''
      chunks.each do |chunk|
        type_pretty = type_pretty + chunk.capitalize + " "
      end
              
      tpl = tpl.sub('{{HEADING}}', "["+type_pretty+" #"+ artifact['id']+"] "+artifact['name'])    
      tpl = tpl.gsub('{{HX}}', hx) # set <hX> tags accordingly to depth
      
      if artifact['descr'].size > 0
        tpl = tpl.sub('{{DESCRIPTION}}', artifact['descr'])    
      else
        tpl = tpl.sub('{{DESCRIPTION}}', t(:export_str_not_available))
      end
      tpl = tpl.sub('{{REQ_URL}}', artifact['url'])
      
    end
    
    tpl
  end
  
  def increase_numbering(depth)
    
    case depth
    when 0
      @chp1 = @chp1 + 1
    when 1
      @chp2 = @chp1 + 1
    when 2
      @chp3 = @chp3 + 1
    when 3
      @chp4 = @chp4 + 1  
    when 4
      @chp5 = @chp5 + 1
    end  
    
  end
  
  def reset_numbering_below(depth)
    depth = depth + 1
    
    case depth
    when 0
      @chp1 = 1
      @chp2 = 1
      @chp3 = 1
      @chp4 = 1
      @chp5 = 1
    when 1
      @chp2 = 1
      @chp3 = 1
      @chp4 = 1
      @chp5 = 1
    when 2
      @chp3 = 1
      @chp4 = 1
      @chp5 = 1
    when 3
      @chp4 = 1
      @chp5 = 1
    when 4
      @chp5 = 1
    end  
  end
  
  def get_chapter_heading(depth, title)
    heading = ''
    
    case depth
    when 0
      # 1. Foo
      heading = @chp1.to_s + " " + title
    when 1
      # 1.1 Bar
      heading = @chp1.to_s + "."+ @chp2.to_s+ " " + title
    when 2
      # 1.1.1 BarFoo
      heading = @chp1.to_s + "."+ @chp2.to_s+ "."+ @chp3.to_s+" " + title
    when 3
      # 1.1.1.1 FooBarFoo
      heading = @chp1.to_s + "."+ @chp2.to_s+ "."+ @chp3.to_s+ "." + @chp4.to_s+" " + title
    when 4
      # 1.1.1.1.1 BarFooBarFoo
      heading = @chp1.to_s + "."+ @chp2.to_s+ "."+ @chp3.to_s+ "." + @chp4.to_s+"."+@chp5.to_s+ " " + title
    end  
        
    heading
  end
  
end