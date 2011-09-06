class BdchartController < ApplicationController
  unloadable


  def index
    @project = Project.find(params[:project_id])

    @allversions = Version.find(:all, :conditions=> ["project_id = ? AND effective_date NOT NULL", @project.id])


    @allversions.sort!{|a,b| a.effective_date <=> b.effective_date }

    currentversion = @allversions.first
    @allversions.each do |version|
      if(Time.now.to_date < version.effective_date)
        currentversion=version
      end
    end
    if currentversion.nil?
      flash[:error] = "Kann Chart nicht berechnen"
    else


    @version_id= (params[:showversion].nil? ? currentversion.id : params[:showversion].to_i)


    puts "\n\n\n"+@version_id.inspect

    dates = version_length[Version.find(@version_id)]

    itlength = version_length[Version.find(@version_id)][2]

    openartifacts = []
    label_days = []
    label_no_of_artifacts = []
    day = dates[0]
    i=1
    dev_duration = 0

    #calc y values of graph
    itlength.to_i.times do
      if (day <= Time.now.to_date)
        openartifacts << number_of_artifacts_open(day, @version_id)
        dev_duration += 1
      else
        openartifacts<<nil
      end

      #label abscissa
      day+=1.days
      label_days << i
      i+=1
    end

    # label ordinate
    (number_of_artifacts_open(dates[0], @version_id)+1).times do |x|
      label_no_of_artifacts << x
    end




    #only print prediction if show version current version
    data =[]
    if(@version_id == currentversion.id)
      prediction = get_prediction_values(openartifacts.slice(0, dev_duration), itlength.to_i)
      data << openartifacts
      data << prediction
    else
      @foo = data = openartifacts
    end




    @charturl =Gchart.line(:size => '750x400',
                           :title => "Chart for #{currentversion.name}",
                           :bg => 'ffffff',
                           :axis_with_labels => ['x', 'y'],
                           :axis_labels => [[label_days], [label_no_of_artifacts]],
                           :data => data,
                           :line_colors => ['FFC400', '76A4FB'],
                           :legend => ['Number of open Artifacts', 'Projection'],
                           :custom => ''
    )

  end
  end


  private


  def get_prediction_values(values, size)
    #m= (y2 - y1) / (x2 - x1)
    m = 0.0
    m =  (values.last.to_f - values.first.to_f) / (values.count.to_f - 0.to_f)
    #n = y2 - m * x2
    n = values.last - m*values.count

    data=[]
    size.times do |i|
      data << ((m*i+n) >= 0 ? m*i+n : nil)
    end
    data
  end


  def number_of_artifacts_open(date, version)
    artifacts = relevant_artifacts(version)
    count=0
    artifacts.each do |artifact|
      if (date_of_closing(artifact).blank? || date_of_closing(artifact) > date)
        count+=1
      end
    end
    count
  end

    #return array with [startdate, enddate, length]
  def version_length()
    versions = Version.find(:all, :conditions => ["project_id=? AND effective_date IS NOT NULL", @project.id])
    versions.sort! { |a, b| a.effective_date <=> b.effective_date }

    itdim = {}
    lastelement = nil
    versions.each do |version|
      if (lastelement.nil?)
        itdim[version]= [version.created_on, version.effective_date, version.effective_date - version.created_on.to_date]
      else
        itdim[version] = [lastelement.effective_date, version.effective_date, version.effective_date - lastelement.effective_date]
      end
      lastelement=version
    end

    itdim
  end

    #returns the date when the last issue of the artifact was closed
  def date_of_closing(artifact)
    date=nil
    artifact.issues.each do |issue|
      journals = issue.journals
      journals.each do |journal|
        journal.details.each do |detail|
          if (detail.prop_key == "status_id" && detail.value.to_i >= 5 && (date.blank? || date<journal.created_on))
            date=journal.created_on
          end
        end
      end
    end

    date
  end


    #artifacts which issues are all scheduled for a given version
  def relevant_artifacts(version)
    issues = find_issues_for_version(version)
    all_artifacts = []

    issues.each do |issue|
      all_artifacts << issue.re_artifact_properties
    end
    all_artifacts.uniq!
    all_artifacts.flatten!

    all_artifacts.delete_if do |artifact|
      artifact.issues.any? { |issue| issue.fixed_version_id!=version }
    end
  end


  def issue_open_at(issue, date)
    open = true
    statusupdates= []
      #get all statusupdates for the issues
    issue.journals.each do |journal|
      journal.details.each do |detail|

        if (detail.prop_key=="status_id")
          statusupdates << detail
        end
      end
    end
    statusupdates.each do |detail|
      if (date_for_statusdetail(detail) < date)
        if (detail.value.to_i<5)
          open=true
        else
          open=false
        end
      end
    end
    open
  end


  def date_for_statusdetail(detail)
    Journal.find(detail.journal_id).created_on
  end


    #find all issues of a given iteration
  def find_issues_for_version(version)
    issues = Issue.find(:all, :conditions => ["fixed_version_id=? AND project_id=?", version, @project.id])
  end


end