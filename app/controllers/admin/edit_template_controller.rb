class EditTemplateController < AdminController
  
  design_editor :holder => 'environment', :autosave => true, :block_types => :block_types

  def block_types
    %w[
       FavoriteLinks
       ListBlock
     ]
  end

  def index
    redirect_to :action => 'design_editor'
  end

end
