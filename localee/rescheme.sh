#/bash/bin!
rake db:rollback STEP=5
rake db:migrate