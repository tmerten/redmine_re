module ReSectionHelper
  
  
  PLUGIN_NAME = File.expand_path('../../*', __FILE__).match(/.*\/(.*)\/\*$/)[1].to_sym

  def plugin_asset_link(asset_name,options={})
    plugin_name=(options[:plugin] ? options[:plugin] : PLUGIN_NAME)
    File.join(Redmine::Utils.relative_url_root,'plugin_assets',plugin_name.to_s,asset_name)
  end
  
end
