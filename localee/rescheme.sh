#/bash/bin!
rake db:rollback STEP=5
rake db:migrate
rake test_controller --trace