Rails.application.routes.draw do

  # For image preview and resize on serve
  if defined? Dragonfly
    Dragonfly.logger = Rails.logger
    endpoint = Dragonfly.app.endpoint do |params, app|
      storage = FileBrowser.storages[params[:storage].to_sym]
      file = storage[Pathname.new params[:path]]
      app.fetch_file(file.stream.path).thumb params[:size]
    end
    get ':storage/uploaded_files/resized/:size/(*path)' => endpoint,
      :as => :resized_uploaded_file, :format => false
  end

  controller :uploaded_files do
    get ':storage/uploaded_files/select/:integration/(*path)' => :index,
      :as => 'select_uploaded_file', :format => false
    get ':storage/uploaded_files/index/(*path)' => :index,
      :as => 'uploaded_files', :format => false
    get ':storage/uploaded_files/(*path)' => :show,
      :as => 'uploaded_file', :format => false
    post ':storage/uploaded_files/drop/:integration' => :create,
      :defaults => {:dropbox => true}, :as => 'drop_uploaded_file'
    post ':storage/uploaded_files/(*path)' => :create,
      :as => 'create_uploaded_file', :format => false
    delete ':storage/uploaded_files/(*path)' => :destroy,
      :as => 'delete_uploaded_file', :format => false
  end
end
