#/bash/bin!
rake db:rollback STEP=5
rake db:migrate
rake generate_fake_data