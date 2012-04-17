class SekaimonSearchJob < AbstractJob
  def morph
    GetApplyJob.new params.merge(:url => 'http://aucfan.com', :filter => 'ident')
  end
  
end