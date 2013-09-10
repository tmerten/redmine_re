class ReArtifactRelationshipController < RedmineReController
  unloadable
  menu_item :re

  TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS = 18
  TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS = 150
  TRUNCATE_OMISSION = "..."

  include ActionView::Helpers::JavaScriptHelper

  def delete
    @relation = ReArtifactRelationship.find(params[:id])

    unless(ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(@relation.relation_type))
      @relation.destroy
    end

    @artifact_properties = ReArtifactProperties.find(params[:re_artifact_properties_id])
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(params[:re_artifact_properties_id])
    @relationships_incoming.delete_if {|rel| ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(rel.relation_type) }

    unless params[:secondary_user_delete].blank?
      @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id_and_relation_type(params[:re_artifact_properties_id],ReArtifactRelationship::RELATION_TYPES[:dep])
      render :partial => "secondary_user", :project_id => params[:project_id]
    else
      @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(params[:re_artifact_properties_id])
      @relationships_outgoing.delete_if {|rel| ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(rel.relation_type) }
      render :partial => "relationship_links", :project_id => params[:project_id]
    end
  end

  def autocomplete_sink
    @artifact = ReArtifactProperties.find(params[:id]) unless params[:id].blank?

    query = '%' + params[:sink_name].gsub('%', '\%').gsub('_', '\_').downcase + '%'
    @sinks = ReArtifactProperties.find(:all, :conditions => ['lower(name) like ? AND project_id = ? AND artifact_type <> ?', query.downcase, @project.id, "Project"])

    if @artifact
      @sinks.delete_if{ |p| p == @artifact }
    end

    list = '<ul>'
    for sink in @sinks
      list << render_autocomplete_artifact_list_entry(sink)
    end
    list << '</ul>'
    render :text => list
  end

  def prepare_relationships
    artifact_properties_id = ReArtifactProperties.get_properties_id(params[:id])
    relation = params[:re_artifact_relationship]

    if ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(relation[:relation_type]) 
      raise ArgumentError, "You are not allowed to create a parentchild relationship!"
    end

    @new_relation = ReArtifactRelationship.new(:source_id => artifact_properties_id, :sink_id => relation[:artifact_id], :relation_type => relation[:relation_type])
    @new_relation.save
    logger.debug("tried saving the following relation (errors: #{@new_relation.errors.size}): " + @new_relation.to_yaml) if logger

    @artifact_properties = ReArtifactProperties.find(artifact_properties_id)
    @relationships_outgoing = ReArtifactRelationship.find_all_by_source_id(artifact_properties_id)
    @relationships_outgoing.delete_if {|rel| ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(rel.relation_type) }
    @relationships_incoming = ReArtifactRelationship.find_all_by_sink_id(artifact_properties_id)
    @relationships_incoming.delete_if {|rel| ReArtifactRelationship::SYSTEM_RELATION_TYPES.values.include?(rel.relation_type) }

    render :partial => "relationship_links", :layout => false, :project_id => params[:project_id]
  end

  def visualization
    session[:visualization_type]=params[:visualization_type]
    session[:visualization_artefakt_id]=params[:artefakt_id]
    @re_artifact_properties = ReArtifactProperties.find(params[:artefakt_id])
    @artifact_name=@re_artifact_properties.name
    
    
    @check_if_filter_are_save_befor = ReRelationshipVisualization.where(
      "project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",
      {:project_id => @project.id, :visualization_type => session[:visualization_type], :artifact_id => session[:visualization_artefakt_id], :user_id => User.current.id }
    ).first
    if @check_if_filter_are_save_befor == nil
      @create_visualization_save_filter = ReRelationshipVisualization.new
      @create_visualization_save_filter.filter_table_add_row(@project.id, session[:visualization_type], session[:visualization_artefakt_id])
    end
    initialize_tree_data
  end

  def build_json_for_visualization(artifacts, relations)
    if (@visualization_type != "graph_issue" )
      @re_artifact_properties = ReArtifactProperties.find_by_id(session[:visualization_artefakt_id])
    end
    json = []

    @done_artifakts_id = []
    @sink_artifakts_id = []
    @source_artifakts_id = []
    @done_artifakts_netmap = []
    
    @found_artifakts = []
    @issues = []
    @done_issues = []
    @visit_issue = []
    @artifacts_netmap_final = []
    
    @current_deep = 0
    @max_deep_over_all = 0
    @min_dis_artifact_arr = []
    @min_dis_issue_arr = []
    
    rootnode = {}
    
    rootnode['id'] = "node0"
    rootnode['name'] = ""
    root_node_data = {}
    root_node_data['$type'] = "none"
    rootnode['data'] = root_node_data

    case @visualization_type
      when "sunburst"
        min_dis_artifact(session[:visualization_artefakt_id].to_i)
        rootnode['name'] = @re_artifact_properties.name
        re_artifact_properties = ReArtifactProperties.find_by_project_id_and_id(@project.id, session[:visualization_artefakt_id])
        children= sunburst(re_artifact_properties)
        rootnode['children'] = children
        rootnode['max_deep'] = @max_deep_over_all
        json = rootnode
        json.to_json
        
      when "netmap"
        min_dis_artifact(session[:visualization_artefakt_id].to_i)
        find_all_artifacts_for_netmap(ReArtifactProperties.find_by_project_id_and_id(@project.id, session[:visualization_artefakt_id]))
        artifacts = @found_artifakts
        json= netmap(artifacts,relations,rootnode)
          
      when "graph"
        @first_run = 0
        json = graph(session[:visualization_artefakt_id],"1")
        json = "[" + json + "]"
      
      when "graph_issue"
        @first_run = 0
        @artifact_connect = []
        json = graph_issue(session[:visualization_artefakt_id].to_i,"1")
        json = "[" + json + "]"
        
    else
      json = rootnode.to_json
    end
    json
  end
  
  def netmap(artifacts, relations, rootnode)
    
    @adjacencies = []
    @artifacts_netmap_final = []
    json = []
    artifacts.each do |artifact|
      adjacent_node = {}
      adjacent_node['nodeTo'] = "node_" + artifact.id.to_s 
      edge_data = {}
      edge_data['$type'] = "none"
      adjacent_node['data'] = edge_data
      @adjacencies << adjacent_node   
      if @chosen_issue
        Realization.where("re_artifact_properties_id = ?", artifact.id.to_s).each do |source|
          @found_artifakts = []
          netmap_issue(source.issue_id,artifacts)
          @found_artifakts.each do |add|
            artifacts << add
          end
        end
      end
      @artifacts_netmap_final << artifact.id
    end
    rootnode['adjacencies'] = @adjacencies
    json << rootnode
    
    artifacts.each do |artifact|
      outgoing_relationships = ReArtifactRelationship.find_all_relations_for_artifact_id(artifact.id)
      drawable_relationships = ReArtifactRelationship.find_all_by_source_id_and_relation_type(artifact.id, relations)
      artifact_ids = @artifacts.collect { |a| a.id }
      drawable_relationships.delete_if { |r| ! artifact_ids.include? r.sink_id }
      json << add_artifact(artifact, drawable_relationships, outgoing_relationships)
      json.to_json
      @done_artifakts_netmap << artifact.id
    end
    if @chosen_issue
      @done_issues.each do |issue_id|
        json << add_issues_netmap(issue_id)
        json.to_json
      end
    end
    json
  end
  
  def netmap_issue(issue_id, artifacts)
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_issue_arr[issue_id]
    end
    if (@max_deep.to_i == 0 || @current_deep.to_i <= @max_deep.to_i)
      if(! @issues.include? issue_id)
     #   @current_deep = @current_deep +1
        @issues << issue_id
    
        adjacent_node = {}
        adjacent_node['nodeTo'] = "node_issue_" + issue_id.to_s
        edge_data = {}
        edge_data['$type'] = "none"
        adjacent_node['data'] = edge_data
        @adjacencies << adjacent_node  
        @done_issues << issue_id
    
        IssueRelation.where("issue_from_id = ?", issue_id.to_s).each do |issue|
          if ( !@issues.include? issue.issue_to_id)
            netmap_issue(issue.issue_to_id, artifacts)
          end
        end
        Realization.where("issue_id = ?", issue_id.to_s).each do |new_artifact|
          next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(new_artifact.re_artifact_properties_id).artifact_type.to_s)
          if((! artifacts.include? new_artifact.re_artifact_properties_id.to_s) && (! @found_artifakts.include? new_artifact.re_artifact_properties_id))
            find_all_artifacts_for_netmap(ReArtifactProperties.find_by_project_id_and_id(@project.id, new_artifact.re_artifact_properties_id.to_s))
          end
        #  @current_deep = @current_deep - 1
        end
      end
    end
  end
  
  def graph(artifact_id,first_run)
    min_dis_artifact(artifact_id)
    re_artifact_properties = ReArtifactProperties.find_by_project_id_and_id(@project.id, artifact_id)
    json = get_all_artifacts_for_graph(re_artifact_properties,first_run)
    json
  end

  def graph_issue(issue_id,first_run)
    min_dis_issue(issue_id)
    json = get_issues_for_graph(issue_id,first_run)
    json
  end

  def sunburst(artifact)
    children = []
    lokal_artifact= []
    if (@max_deep == 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_artifact_arr[artifact.id]
    end
    if (@max_deep.to_i == 0 || @current_deep.to_i < @max_deep.to_i)
      
      if @chosen_relations.include?("dependency")
        lokal_artifact = artifact.dependency
      end
      if @chosen_relations.include?("conflict")
        lokal_artifact = artifact.conflict
      end
      if @chosen_relations.include?("rationale")
        lokal_artifact = artifact.rationale
      end
      if @chosen_relations.include?("refinement")
        lokal_artifact = artifact.refinement
      end
      if @chosen_relations.include?("part_of")
        lokal_artifact = artifact.part_of
      end
      if @chosen_relations.include?("parentchild")
        lokal_artifact = artifact.children
      end
      if @chosen_relations.include?("primary_actor")
        lokal_artifact = artifact.primary
      end
      if @chosen_relations.include?("actors")
        lokal_artifact = artifact.actors
      end
      if @chosen_relations.include?("diagram")
        lokal_artifact = artifact.diagram
      end
      if (@chosen_issue)
        Realization.where("re_artifact_properties_id=?",artifact.id.to_s).each do |issue|
          next unless ( ! @done_issues.include? issue.issue_id.to_s)
            json_issue = add_issues_netmap(issue.issue_id.to_s)
            issue_return = add_issues_sunburst(issue.issue_id.to_s)
            if(issue_return!= [])
              json_issue['children'] = issue_return
            end
          children << json_issue
        end
      end
    
      for child in lokal_artifact
        next unless (@chosen_artifacts.include? child.artifact_type.to_s)
        next unless ( ! @done_artifakts_id.include? child.id.to_s)
        @done_artifakts_id << artifact.id.to_s
        outgoing_relationships = ReArtifactRelationship.find_all_relations_for_artifact_id(child.id)
        drawable_relationships = ReArtifactRelationship.find_all_by_source_id(child.id)
        json_artifact = add_artifact(child, drawable_relationships, outgoing_relationships)
        json_return = sunburst(child)
        if (json_return != [])
          json_artifact['children'] = json_return
        end
        children << json_artifact
      end
    end
   
    children
  end
  
  def add_issues_sunburst(issue_id)
    children= []
    issue_artifact = {}
    json_artifact = {}
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_issue_arr[issue_id.to_i]
    end
    if (@max_deep.to_i == 0 || @current_deep.to_i < @max_deep.to_i)
      @done_issues << issue_id.to_s
      
      IssueRelation.where("issue_from_id=?",issue_id).each do |issue|
        issue_artifact = add_issues_netmap(issue.issue_to_id.to_s)
        issue_artifact['children'] = add_issues_sunburst(issue.issue_to_id.to_s)
        children << issue_artifact
      end
      Realization.where("issue_id=?", issue_id.to_s).each do |artifact| 
        if( ! @done_artifakts_id.include? artifact.re_artifact_properties_id.to_s)
          outgoing_relationships = ReArtifactRelationship.find_all_relations_for_artifact_id(artifact.re_artifact_properties_id)
          drawable_relationships = ReArtifactRelationship.find_all_by_source_id(artifact.re_artifact_properties_id)
          child = ReArtifactProperties.find_by_project_id_and_id(@project.id,artifact.re_artifact_properties_id) 
       
          json_artifact = add_artifact(child, drawable_relationships, outgoing_relationships)
          json_artifact['children'] = sunburst(child)
       
          children << json_artifact
        end
      end
    end
    
    children
    
  end

  def get_all_artifacts_for_graph(artifact,first_run)
    issues = []
    adjacencies = []
    master_build = {}
    rootnode = {}
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_artifact_arr[artifact.id]
    end
    if (@max_deep.to_i == 0 || @current_deep.to_i <= @max_deep.to_i)
    #  @current_deep = @current_deep.to_i + 1
      if ( ! @done_artifakts_id.include? artifact.id.to_s)
          ReArtifactRelationship.find_all_by_source_id(artifact.id).each do |source|
            next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.sink_id).artifact_type.to_s)
            next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
            
            if (@current_deep.to_i  == @max_deep.to_i)
               if(! @done_artifakts_id.include? source.sink_id.to_s)
                 next
               end
            end
            if (  @source_artifakts_id.include? source.source_id) 
              if(  @sink_artifakts_id.include? source.sink_id.to_s) 
                next
              end
            end
            adjacent_node = {}
            adjacent_node['nodeTo'] = "node_" + source.sink_id.to_s
            adjacent_node['nodeFrom'] = "node_" + source.source_id.to_s
            
            relation_settings = ReSetting.get_serialized(source.relation_type, @project.id)
            
            edge_data = {}
            edge_data['$color'] = relation_settings['color']
            adjacent_node['data'] = edge_data
            adjacencies << adjacent_node  
            if ( ! @source_artifakts_id.include? source.source_id) 
              @source_artifakts_id << source.source_id
            end
          end
          ReArtifactRelationship.find_all_by_sink_id(artifact.id).each do |source|
            next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.source_id).artifact_type.to_s)
            next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
            if (@current_deep.to_i  == @max_deep.to_i)
              if(! @done_artifakts_id.include? source.source_id.to_s)
                next
              end
            end
            if (  @source_artifakts_id.include? source.source_id) 
              if(  @sink_artifakts_id.include? source.sink_id )
                next
              end
            end
            adjacent_node = {}
            adjacent_node['nodeTo'] = "node_" + source.source_id.to_s
            adjacent_node['nodeFrom'] = "node_" + source.sink_id.to_s
            edge_data = {}
            relation_settings = ReSetting.get_serialized(source.relation_type, @project.id)
            edge_data['$color'] = relation_settings['color']
            adjacent_node['data'] = edge_data
            adjacencies << adjacent_node  
            if ( ! @sink_artifakts_id.include? source.sink_id) 
              @sink_artifakts_id << source.sink_id
            end
          end
          if @chosen_issue
            Realization.where("re_artifact_properties_id = ?", artifact.id.to_s).each do |source|
              if (@current_deep.to_i  == @max_deep.to_i)
                if( ! @done_issues.include? source.issue_id)
                  next
                end
              end
              adjacent_node = {}
              adjacent_node['nodeTo'] = "node_issue_" + source.issue_id.to_s
              adjacent_node['nodeFrom'] = "node_" + artifact.id.to_s
              edge_data = {}
              edge_data['$color'] = '#000000'
              adjacent_node['data'] = edge_data
              adjacencies << adjacent_node  
              if ( !@done_issues.include? source.issue_id)
                issues << source.issue_id
              end
            end
          end

        type = artifact.artifact_type
        node_settings = ReSetting.get_serialized(type.underscore, @project.id)
        data_node = {}
   
        if (node_settings != nil)
          data_node["$color"] = node_settings['color']
        else
          data_node["$color"] = "#83548B"
        end
        if (first_run == "1")
          data_node["$type"] = "star" #"triangle" #"square"
          first_run = 1
        else
            data_node["$type"] = "circle"
        end
        data_node['full_name'] = artifact.name
        data_node['description'] = truncate(artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        data_node['created_at'] = artifact.created_at.to_s(:short)
        data_node['author'] = artifact.author.to_s
        data_node['updated_at'] = artifact.updated_at.to_s(:short)
        data_node['user'] = artifact.user.to_s
        data_node['responsibles'] = artifact.responsible.name unless artifact.responsible.nil?  
        data_node["$dim"] = 10

        relationship_data = []
        ReArtifactRelationship.where("source_id=?",artifact.id).each do |relation| 
          other_artifact = ReArtifactProperties.find(relation.sink_id)
          unless other_artifact.nil? # TODO: actually, this should not possible
          relation_data = {}
          relation_data['id'] = other_artifact.id
          relation_data['full_name'] = other_artifact.name
          relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
          relation_data['created_at'] = other_artifact.created_at.to_s(:short)
          relation_data['author'] = other_artifact.author.to_s
          relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
          relation_data['user'] = other_artifact.user.to_s
          relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
          relation_data['relation_type'] = relation.relation_type
          relation_data['direction'] = 'to'
          relationship_data << relation_data
        end
      
      
        ReArtifactRelationship.where("sink_id=?",artifact.id).each do |relation|
          other_artifact = ReArtifactProperties.find(relation.source_id)
          unless other_artifact.nil? # TODO: actually, this should not possible
          relation_data = {}
          relation_data['id'] = other_artifact.id
          relation_data['full_name'] = other_artifact.name
          relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
          relation_data['created_at'] = other_artifact.created_at.to_s(:short)
          relation_data['author'] = other_artifact.author.to_s
          relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
          relation_data['user'] = other_artifact.user.to_s
          relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
          relation_data['relation_type'] = relation.relation_type
          relation_data['direction'] = 'to'
          relationship_data << relation_data
        end
      end
    end
    Realization.where("re_artifact_properties_id=?",artifact.id).each do |relation|
      other_artifact = Issue.find(relation.issue_id)
      unless other_artifact.nil? # TODO: actually, this should not possible
      relation_data = {}
      relation_data['id'] = other_artifact.id
      relation_data['full_name'] = other_artifact.subject
      relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
      relation_data['created_at'] = other_artifact.created_on.to_s(:short)
      relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
      relation_data['relation_type'] = "Issue_to_Artifact"
      relation_data['direction'] = 'to'
      relationship_data << relation_data
    end
    end

      data_node['relationship_data'] = relationship_data  
      master_build["data"] = data_node 
      master_build["id"] = 'node_' + artifact.id.to_s
      master_build["name"] = ReArtifactProperties.find_by_id(artifact.id).name.to_s
      
      rootnode['adjacencies'] = adjacencies 
      short_save = rootnode.to_json
      short_save = short_save.chop
      short_save2=master_build.to_json
      short_save2 = short_save2[1,short_save2.length]
      
      json = short_save + "," + short_save2  
      
      @done_artifakts_id << artifact.id.to_s  
    end

    ReArtifactRelationship.find_all_by_source_id(artifact.id).each do |source|
      next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.sink_id).artifact_type.to_s)
      next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
      next unless ( ! @done_artifakts_id.include? source.sink_id.to_s)

      json_return = get_all_artifacts_for_graph(ReArtifactProperties.find_by_project_id_and_id(@project.id, source.sink_id),0)  
      if (json != nil)
        if (json_return != nil)
          json = json + "," + json_return
        end
      else
        if (json_return != nil)
          json =  json_return
        end
      end
    end 
    ReArtifactRelationship.find_all_by_sink_id(artifact.id).each do |source|
      next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.source_id).artifact_type.to_s)
      next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
      next unless ( ! @done_artifakts_id.include? source.source_id.to_s)

      json_return = get_all_artifacts_for_graph(ReArtifactProperties.find_by_project_id_and_id(@project.id, source.source_id),0)  
      if (json != nil)
        if (json_return != nil)
          json = json + "," + json_return
        end
      else
        if (json_return != nil)
          json =  json_return
        end
      end
      
    end
    issues.each do |issue_id|
      json_return=get_issues_for_graph(issue_id,0)
      if (json != nil)
        if (json_return != nil)
          json = json + "," + json_return
        end
      else
        if (json_return != nil)
          json =  json_return
        end
      end
      
    end
       
 #   @current_deep = @current_deep.to_i - 1
  end
    json
  end 
  
  def get_issues_for_graph(issue_id,first_run)
    issues = []
    artifact = []
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_issue_arr[issue_id]
    end
  
    if (@max_deep.to_i == 0 || @current_deep.to_i <= @max_deep.to_i)
     # @current_deep = @current_deep.to_i + 1
      adjacencies = []
      master_build = {}
      rootnode = {}
      if ( ! @done_issues.include? issue_id )
        IssueRelation.where("issue_from_id = ?", issue_id.to_s).each do |source|
          if (@current_deep.to_i  == @max_deep.to_i)
            if(! @done_issues.include? source.issue_to_id)
              next
            end
          end
          adjacent_node = {}
          adjacent_node['nodeTo'] = "node_issue_" + source.issue_to_id.to_s
          adjacent_node['nodeFrom'] = "node_issue_" + source.issue_from_id.to_s
        
          edge_data = {}
          edge_data['$color'] = "#000000"
          adjacent_node['data'] = edge_data
          adjacencies << adjacent_node  
          if ( ! @done_issues.include? source.issue_to_id) 
              issues << source.issue_to_id
          end
        end
        IssueRelation.where("issue_to_id = ?", issue_id.to_s).each do |source|
          if (@current_deep.to_i  == @max_deep.to_i)
            if(! @done_issues.include? source.issue_from_id)
              next
            end
          end
          adjacent_node = {}
          adjacent_node['nodeTo'] = "node_issue_" + source.issue_from_id.to_s
          adjacent_node['nodeFrom'] = "node_issue_" + source.issue_to_id.to_s
        
          edge_data = {}
          edge_data['$color'] = "#000000"
          adjacent_node['data'] = edge_data
          adjacencies << adjacent_node  
          if ( ! @done_issues.include? source.issue_from_id) 
              issues << source.issue_from_id
          end
        end
        
        Realization.where("issue_id=?",issue_id).each do |relation|
          next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(relation.re_artifact_properties_id).artifact_type.to_s) 
          if (@current_deep.to_i  == @max_deep.to_i)
            if(! @done_artifakts_id.include? relation.re_artifact_properties_id.to_s)
              next
            end
          end
          adjacent_node = {}
          adjacent_node['nodeTo'] = "node_" + relation.re_artifact_properties_id.to_s
          adjacent_node['nodeFrom'] = "node_issue_" + relation.issue_id.to_s
        
          edge_data = {}
          edge_data['$color'] = "#000000"
          adjacent_node['data'] = edge_data
          adjacencies << adjacent_node  
          if ( ! artifact.include? relation.re_artifact_properties_id) 
            artifact << relation.re_artifact_properties_id
          end
        end
      
      data_node = {}
      data_node["$color"] = "#123456"
      if (first_run == "1")
        data_node["$type"] = "triangle" 
        first_run = 1
      else
           data_node["$type"] = "square" #"triangle" #"square"
      end
     
      this_issue=Issue.find(issue_id)  
      data_node['full_name'] = this_issue.subject
      data_node['description'] = this_issue.description
      data_node['created_at'] = this_issue.created_on.to_s(:short)
    
      data_node['author'] = User.find(this_issue.author_id).lastname
      data_node['updated_at'] = this_issue.updated_on.to_s(:short)
   
      data_node["$dim"] = 10
      relationship_data = []
   
      Realization.where("issue_id=?",issue_id).each do |relation|
        other_artifact = ReArtifactProperties.find(relation.re_artifact_properties_id)
        unless other_artifact.nil? # TODO: actually, this should not possible
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.name
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_at.to_s(:short)
        relation_data['author'] = other_artifact.author.to_s
        relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
        relation_data['user'] = other_artifact.user.to_s
        relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
        relation_data['relation_type'] = "Issue_to_Artifact"
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end
    IssueRelation.where("issue_from_id=?",issue_id).each do |relation|
      other_artifact = Issue.find(relation.issue_to_id)
      unless other_artifact.nil? # TODO: actually, this should not possible
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.subject
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_on.to_s(:short)
        relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
        relation_data['relation_type'] = "Issue"
        relation_data['direction'] = 'to'
        
        relationship_data << relation_data
      end
    end
    IssueRelation.where("issue_to_id=?",issue_id).each do |relation|
      other_artifact = Issue.find(relation.issue_from_id)
      unless other_artifact.nil? # TODO: actually, this should not possible
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.subject
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_on.to_s(:short)
        relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
        relation_data['relation_type'] = "Issue"
        relation_data['direction'] = 'to'
        
        relationship_data << relation_data
      end
    end

    data_node['relationship_data'] = relationship_data  
       
    master_build["data"] = data_node 
    master_build["id"] = 'node_issue_' + issue_id.to_s
    master_build["name"] = Issue.find_by_id(issue_id).subject.to_s
      
    rootnode['adjacencies'] = adjacencies 
    short_save = rootnode.to_json
    short_save = short_save.chop
    short_save2=master_build.to_json
    short_save2 = short_save2[1,short_save2.length]
      
    json = short_save + "," + short_save2  
      
    @done_issues << issue_id  
    
      end
    end
    issues.each do |issue_id|
      json_return=get_issues_for_graph(issue_id,0)
      if (json != nil)
        if (json_return != nil)
          json = json + "," + json_return
        end
      else
        if (json_return != nil)
          json =  json_return
        end
      end
      
    end
    
    artifact.each do |artifact_id|
      re_artifact_properties = ReArtifactProperties.find_by_project_id_and_id(@project.id, artifact_id)
      json_return = get_all_artifacts_for_graph(re_artifact_properties,"0")
      if (json != nil)
        if (json_return != nil)
          json = json + "," + json_return
        end
      else
        if (json_return != nil)
          json =  json_return
        end
      end
      
 #   @current_deep = @current_deep.to_i - 1 
    end
   
    json
  end
  
  def find_all_artifacts_for_netmap(artifact)
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_artifact_arr[artifact.id]
    end
    if (@max_deep.to_i == 0 || @current_deep.to_i <= @max_deep.to_i)
      
      re_artifact_properties = ReArtifactProperties.find_by_id(artifact.id)
      if re_artifact_properties.artifact_type.to_s != "Project"
        @found_artifakts << artifact
        @done_artifakts_id << artifact.id.to_s
      end
      ReArtifactRelationship.find_all_by_source_id(artifact.id).each do |source|
        next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.sink_id).artifact_type.to_s)
        next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
        next unless ( ! @done_artifakts_id.include? source.sink_id.to_s)
        find_all_artifacts_for_netmap(ReArtifactProperties.find_by_project_id_and_id(@project.id, source.sink_id))  
      end 
      ReArtifactRelationship.find_all_by_sink_id(artifact.id).each do |source|
        next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.source_id).artifact_type.to_s)
        next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
        next unless ( ! @done_artifakts_id.include? source.source_id.to_s)
        find_all_artifacts_for_netmap(ReArtifactProperties.find_by_project_id_and_id(@project.id, source.source_id))  
      end 
    end
  end

  def add_artifact(artifact, drawable_relationships, outgoing_relationships)
    type = artifact.artifact_type
    node_settings = ReSetting.get_serialized(type.underscore, @project.id)

    node = {}
    node['id'] = "node_" + artifact.id.to_s
    node['name'] = truncate(artifact.name, :length => TRUNCATE_NAME_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)

    node_data = {}
    node_data['full_name'] = artifact.name
    node_data['description'] = truncate(artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    node_data['created_at'] = artifact.created_at.to_s(:short)
    node_data['author'] = artifact.author.to_s
    node_data['updated_at'] = artifact.updated_at.to_s(:short)
    node_data['user'] = artifact.user.to_s
    node_data['responsibles'] = artifact.responsible.name unless artifact.responsible.nil?
    
    node_data['$color'] = node_settings['color']
    node_data['$height'] = 90
    node_data['$angularWidth'] = 13


    adjacencies= []

    relationship_data = []
    outgoing_relationships.each do |relation|
      other_artifact = relation.sink
      unless other_artifact.nil? # TODO: actually, this should not possible
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.name
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_at.to_s(:short)
        relation_data['author'] = other_artifact.author.to_s
        relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
        relation_data['user'] = other_artifact.user.to_s
        relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
        relation_data['relation_type'] = relation.relation_type
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end
    Realization.where("re_artifact_properties_id=?",artifact.id).each do |relation|
      other_artifact = Issue.find(relation.issue_id)
      unless other_artifact.nil? # TODO: actually, this should not possible
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.subject
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_on.to_s(:short)
        relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
        relation_data['relation_type'] = "Issue"
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end

    node_data['relationship_data'] = relationship_data 
    node['data'] = node_data
    if (@max_deep== 0)
      @current_deep = 1
    else
      @current_deep = @min_dis_artifact_arr[artifact.id]
    end
    if (@current_deep != @max_deep || @max_deep == 0)
      
      drawable_relationships.each do |relation|
        sink = ReArtifactProperties.find_by_id(relation.sink_id)
        directed = ReArtifactRelationship.find_by_source_id_and_sink_id(relation.sink_id, relation.source.id).nil?
        relation_settings = ReSetting.get_serialized(relation.relation_type, @project.id)
        if(@visualization_type == "netmap")
          if(@artifacts_netmap_final.include? sink.id)
            doit=true
          else
            doit=false
          end
        else
          doit=true
        end
        if(doit)
          adjacent_node = {}
          adjacent_node['nodeTo'] = "node_" + sink.id.to_s
      
          edge_data = {}
          edge_data['$color'] = relation_settings['color'] if directed
          edge_data['$color'] = "#111111" unless directed
          edge_data['$lineWidth'] = 2
          edge_data['$type'] = "arrow" if directed
          edge_data['$direction'] = [ "node_" + artifact.id.to_s, "node_" + sink.id.to_s ] if directed
          edge_data['$type'] = "hyperline" unless directed
          adjacent_node['data'] = edge_data

          adjacencies << adjacent_node
        end
      end
    
    #Add Connection to Issues
      if @chosen_issue
        Realization.where("re_artifact_properties_id = ?", artifact.id.to_s).each do |source|
          if(@visualization_typ="netmap")
            if(@issues.include? source.issue_id )
              doit=true
            else
              doit=false
            end
          else
            doit=true
          end
          if (doit)
            adjacent_node = {}
            adjacent_node['nodeTo'] = "node_issue_" + source.issue_id.to_s
      
            edge_data = {}
            edge_data['$color'] = "#123456"
            edge_data['$lineWidth'] = 2
            edge_data['$type'] = "arrow" 
            edge_data['$direction'] = [ "node_" + artifact.id.to_s, "node_issue_" + source.issue_id.to_s ] 
            edge_data['$type'] = "hyperline" 
            adjacent_node['data'] = edge_data

            adjacencies << adjacent_node
            @done_issues << source.issue_id
          end
        end
        
      end
    node['adjacencies'] = adjacencies
    end
    node
  end
  
  def add_issues_netmap(issue_id)
    
    node = {}
    node['id'] = "node_issue_" + issue_id.to_s
    issue_data=Issue.find(issue_id)
    node['name'] = issue_data.subject

    node_data = {}
    node_data['full_name'] = issue_data.subject
    node_data['description'] = truncate(issue_data.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
    node_data['created_at'] = issue_data.created_on.to_s(:short)
    node_data['author'] = User.find(issue_data.author_id).lastname
    node_data['updated_at'] = issue_data.updated_on.to_s(:short)
    node_data['$color'] = "#123456"
    node_data['$height'] = 90
    node_data['$angularWidth'] = 13.00

    adjacencies= []

    relationship_data = []
    Realization.where("issue_id = ?", issue_id.to_s).each do |source|
      ReArtifactProperties.where("id = ?",source.re_artifact_properties_id).each do |other_artifact|
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.name
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_at.to_s(:short)
        relation_data['author'] = other_artifact.author.to_s
        relation_data['updated_at'] = other_artifact.updated_at.to_s(:short)
        relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
        relation_data['relation_type'] = "Issue_to_Artifact"
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end
    IssueRelation.where("issue_from_id = ?", issue_id.to_s).each do |source|
      Issue.where("id = ?",source.issue_to_id).each do |other_artifact|
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.subject
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_on.to_s(:short)
        relation_data['author'] = other_artifact.author.to_s
        relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
       # relation_data['responsibles'] = other_artifact.responsible.name unless other_artifact.responsible.nil? 
        relation_data['relation_type'] = "Issue"
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end
    IssueRelation.where("issue_to_id = ?", issue_id.to_s).each do |source|
      Issue.where("id = ?",source.issue_from_id).each do |other_artifact|
        relation_data = {}
        relation_data['id'] = other_artifact.id
        relation_data['full_name'] = other_artifact.subject
        relation_data['description'] = truncate(other_artifact.description, :length => TRUNCATE_DESCRIPTION_IN_VISUALIZATION_AFTER_CHARS, :omission => TRUNCATE_OMISSION)
        relation_data['created_at'] = other_artifact.created_on.to_s(:short)
        relation_data['author'] = other_artifact.author.to_s
        relation_data['updated_at'] = other_artifact.updated_on.to_s(:short)
        relation_data['relation_type'] = "Issue"
        relation_data['direction'] = 'to'
        relationship_data << relation_data
      end
    end

    node_data['relationship_data'] = relationship_data 
    node['data'] = node_data

    #Add Connection to Issues
    IssueRelation.where("issue_from_id = ?", issue_id.to_s).each do |source|
      if (@issues.include? source.issue_to_id )  
        adjacent_node = {}
        adjacent_node['nodeTo'] = "node_issue_" + source.issue_to_id.to_s
    
        edge_data = {}
        edge_data['$color'] = "#123456"
        edge_data['$lineWidth'] = 2
        edge_data['$type'] = "arrow" 
        edge_data['$direction'] = [ "node_issue_" + issue_id.to_s, "node_issue_" + source.issue_to_id.to_s ] 
        edge_data['$type'] = "hyperline" 
        adjacent_node['data'] = edge_data
        adjacencies << adjacent_node
      end
    end
    
    Realization.where("issue_id=?", issue_id.to_s).each do |source|
      next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.re_artifact_properties_id).artifact_type.to_s)
      if(@done_artifakts_netmap.include? source.re_artifact_properties_id)
        adjacent_node = {}
        adjacent_node['nodeTo'] = "node_" + source.re_artifact_properties_id.to_s
      
        edge_data = {}
        edge_data['$color'] = "#123456"
        edge_data['$lineWidth'] = 2
        edge_data['$type'] = "arrow" 
        edge_data['$direction'] = [ "node_issue_" + issue_id.to_s, "node_" + source.re_artifact_properties_id.to_s ] 
        edge_data['$type'] = "hyperline" 
        adjacent_node['data'] = edge_data
        adjacencies << adjacent_node
      end
    end
    node['adjacencies'] = adjacencies
    node
  end
  
  def build_json_according_to_user_choice
    # This method build a new json string in variable @json_netmap which is returned
    # Meanwhile it computes queries for the search for the chosen artifacts and relations.
    # ToDo Refactor this method: The same is done for relationships and artifacts --> outsource!
 
    # String for condition to find the chosen artifacts

    @chosen_artifacts = []
    @chosen_relations = []
    @json_netmap = []
    @chosen_issue = false
    @max_deep = 0
    
    if (params[:artefakt_id].present?)
      session[:visualization_artefakt_id] = params[:artefakt_id]
    end
    
    if (params[:visualization_type].present?)
      session[:visualization_type] = params[:visualization_type]
    end
    
    @visualization_type  = session[:visualization_type]
    
    @visualization_filter = ReRelationshipVisualization.new
    if (params[:relation_filter].present?)
      @visualization_filter.relationship_save(@project.id, params[:relation_filter], session[:visualization_type], session[:visualization_artefakt_id])
    end
    if (params[:artifact_filter].present?)
      @visualization_filter.artifact_save(@project.id, params[:artifact_filter], session[:visualization_type], session[:visualization_artefakt_id])
    end
    if(params[:deep].present?)
      deep=params[:deep].to_i.to_s
      
      if(deep != params[:deep].to_s)
        if (session[:visualization_type]!= "netmap")
          deep = ReSetting.get_plain("visualization_deep", @project.id).to_i
        else
          deep = 0
        end
      end
      @visualization_filter.save_max_deep(@project.id, deep, session[:visualization_type], session[:visualization_artefakt_id])
    end
   
   if(params[:data].present?)
     #tooltip-graph
     @re_artifact_order = ReSetting.get_serialized("artifact_order", @project.id)
     @re_relation_order = ReSetting.get_serialized("relation_order", @project.id)
     @re_artifact_order.each_with_index do |artifact_type, i|
        relation_settings = ReSetting.get_serialized(artifact_type, @project.id)
        if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
          lokal_artifact=artifact_type.gsub(/^re_/, '').humanize
          @chosen_artifacts << "Re"+lokal_artifact.to_s
        end
      end
      @re_relation_order.each_with_index do |relation_type, i|
         relation_settings = ReSetting.get_serialized(relation_type, @project.id)
         if(relation_settings['show_in_visualization'] == true || relation_settings['show_in_visualization'] == "yes" )
           @chosen_relations << relation_type.to_s
         end
       end
       issue = ReSetting.get_plain("issues", @project.id)
       if (issue == "yes" || issue == true)
         @chosen_issue = true
       else
         @chosen_issue = false
       end
       @max_deep = ReSetting.get_serialized("visualization_deep", @project.id).to_i
   else
       @check_if_filter_are_save_befor = ReRelationshipVisualization.where(
       "project_id = :project_id AND visualization_typ = :visualization_type AND artefakt_id = :artifact_id AND user_id = :user_id",
        {:project_id => @project.id, :visualization_type => session[:visualization_type], :artifact_id => session[:visualization_artefakt_id], :user_id => User.current.id }
        ).first
       if @check_if_filter_are_save_befor == nil
         @create_visualization_save_filter = ReRelationshipVisualization.new
         @create_visualization_save_filter.filter_table_add_row(@project.id, session[:visualization_type], session[:visualization_artefakt_id])
       end
    
       @chosen_artifacts = @visualization_filter.get_artifact_filter_as_stringarray(@project.id, session[:visualization_type], session[:visualization_artefakt_id])
       @chosen_relations = @visualization_filter.get_relation_filter_as_stringarray(@project.id, session[:visualization_type], session[:visualization_artefakt_id])
       @chosen_issue = @visualization_filter.get_issue_filter(@project.id, session[:visualization_type], session[:visualization_artefakt_id])
       @max_deep = @visualization_filter.get_max_deep(@project.id, session[:visualization_type], session[:visualization_artefakt_id]).to_i
   end
   if(@visualization_type!= "graph_issue" )
     @artifacts = ReArtifactProperties.find_all_by_project_id_and_artifact_type(@project.id, @chosen_artifacts, :order => "artifact_type, name")
   else
     @artifacts = ""
   end
    @json_netmap = build_json_for_visualization(@artifacts, @chosen_relations)

    render :json => @json_netmap
  end
  def min_dis_artifact(artifact_id)
    @current_deep = @current_deep + 1
    ReArtifactRelationship.find_all_by_source_id(artifact_id).each do |source|
      next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.sink_id).artifact_type.to_s)
      next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
     
      if (@min_dis_artifact_arr[source.sink_id] == nil || @min_dis_artifact_arr[source.sink_id] > @current_deep)
        @min_dis_artifact_arr[source.sink_id] = @current_deep  
        min_dis_artifact(source.sink_id)
        if (@current_deep > @max_deep_over_all)
          @max_deep_over_all = @current_deep
        end
      end
    end 
    if(@visualization_type != "sunburst")
      ReArtifactRelationship.find_all_by_sink_id(artifact_id).each do |source|
        next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(source.source_id).artifact_type.to_s)
        next unless (@chosen_relations.include? ReArtifactRelationship.find_by_id(source.id).relation_type.to_s)
        if (@min_dis_artifact_arr[source.source_id] == nil || @min_dis_artifact_arr[source.source_id] > @current_deep)
          @min_dis_artifact_arr[source.source_id] = @current_deep  
          min_dis_artifact(source.source_id)
          if (@current_deep>@max_deep_over_all)
            @max_deep_over_all = @current_deep
          end
        end
      end
    end
    if @chosen_issue
      Realization.where("re_artifact_properties_id = ?", artifact_id.to_s).each do |source|
        if (@min_dis_issue_arr[source.issue_id] == nil || @min_dis_issue_arr[source.issue_id] > @current_deep)
          @min_dis_issue_arr[source.issue_id] = @current_deep  
          min_dis_issue(source.issue_id)
          if (@current_deep>@max_deep_over_all)
            @max_deep_over_all = @current_deep
          end
        end
      end
      @current_deep = @current_deep - 1
    end
  end
  
  def min_dis_issue(issue_id)
    @current_deep = @current_deep + 1
    Realization.where("issue_id=?",issue_id).each do |relation|
    next unless (@chosen_artifacts.include? ReArtifactProperties.find_by_id(relation.re_artifact_properties_id).artifact_type.to_s)
      if (@min_dis_artifact_arr[relation.re_artifact_properties_id] == nil || @min_dis_artifact_arr[relation.re_artifact_properties_id] > @current_deep)
        @min_dis_artifact_arr[relation.re_artifact_properties_id] = @current_deep  
        min_dis_artifact(relation.re_artifact_properties_id)
        if (@current_deep>@max_deep_over_all)
          @max_deep_over_all = @current_deep
        end
      end
    end
  
    IssueRelation.where("issue_from_id=?",issue_id).each do |relation|
      if (@min_dis_issue_arr[relation.issue_to_id] == nil || @min_dis_issue_arr[relation.issue_to_id] > @current_deep)
        @min_dis_issue_arr[relation.issue_to_id] = @current_deep  
        min_dis_issue(relation.issue_to_id)
        if (@current_deep>@max_deep_over_all)
          @max_deep_over_all = @current_deep
        end
      end
    end
  
    IssueRelation.where("issue_to_id=?",issue_id).each do |relation|
      if (@min_dis_issue_arr[relation.issue_from_id] == nil || @min_dis_issue_arr[relation.issue_from_id] > @current_deep)
        @min_dis_issue_arr[relation.issue_from_id] = @current_deep  
        min_dis_issue(relation.issue_from_id)
        if (@current_deep>@max_deep_over_all)
          @max_deep_over_all = @current_deep
        end
      end
    end
    @current_deep = @current_deep - 1
  end
 
end
