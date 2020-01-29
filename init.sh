#! /bin/bash

## Create local environment variables
GREEN='\033[0;32m'
NC='\033[0m'
BOLD='\e[1m'
NORMAL='\e[21m'
DIM='\e[2m'
END='\e[0m'

printf "${GREEN}Will this website be hosted on Pantheon? [${BOLD}Y${END}${GREEN}${NORMAL}/${END}${GREEN}${DIM}n${END}${GREEN}${NORMAL}]:${NC}"
read pantheonEnv
pantheonEnv=${pantheonEnv:-Y}

if [ "$pantheonEnv" != "n" ]; then
    printf "\n${GREEN}Great! If you haven't already authenticated a Pantheon machine token for this machine, please do so now.\nGo to this URL to generate a machine token: https://pantheon.io/docs/machine-tokens/\n\n${END}"
    printf "${GREEN}Have you already authenticated your Pantheon machine token? If so, type 'Y'; if not, please enter your token:${END} "
    read machineToken

    if [ "$gitRepo" != "y" ]; then
      ddev auth pantheon ${machineToken}
    fi

    printf "${GREEN}\nThanks! Please verify the Pantheon project is set to Git mode and a Pantheon Backup of the Dev environment is created.\nAfter this has been done, enter the full git clone command (including git clone): ${END}"
    read gitClone
    ## git clone and start the application set up
    ${gitClone}
    projectName=$(echo $gitClone | awk '{print $NF}')
    ddev config pantheon --http-port 8000 --project-name=${projectName} --docroot=./${projectName} --pantheon-environment=dev
    ddev pull -y
    ddev start
    printf "${GREEN}DDEV local site ready! Would you like to set up your bootstrap theme? [Y/n]:${END}"
    read setUpBootstrap

    if [ "$setUpBootstrap" != "n" ]; then
      themeName=${projectName//-/_}
      themeTitle=${projectName//-/ }
      cd ${projectName}/themes
      mkdir contrib custom
      cd contrib
      git clone https://github.com/drupalprojects/bootstrap.git
      printf "${GREEN}\nDrupal Theme Name: ${themeName}${END}\n"
      printf "${GREEN}\nDrupal Theme Title: ${themeTitle}${END}\n"
      cp -R bootstrap/starterkits/sass ../custom/${themeName}
      cd ../custom/${themeName}
      mv THEMENAME.libraries.yml ${themeName}.libraries.yml
      mv THEMENAME.starterkit.yml ${themeName}.info.yml
      mv THEMENAME.theme ${themeName}.theme
      mv config/install/THEMENAME.settings.yml config/install/${themeName}.settings.yml
      mv config/schema/THEMENAME.schema.yml config/schema/${themeName}.schema.yml
      sleep 3
      sed -i.bak -e "s/THEMENAME/${themeName}/g;s/THEMETITLE/${themeTitle}/g" ${themeName}.info.yml
      sed -i.bak -e "s/THEMENAME/${themeName}/g;s/THEMETITLE/${themeTitle}/g" config/schema/${themeName}.schema.yml
      printf "${GREEN}\nGreat, we're all done here. Happy coding!\n\n${END}"
    else
      printf "${GREEN}\nGreat, we're all done here. Happy coding!\n\n${END}"
    fi;
else
    printf "${GREEN}Great! What would you like the project name to be? Hyphens and alphanumeric characters only please:${END} "
    read projectName
    themeName=${projectName//-/_}
    themeTitle=${projectName//-/ }

    ## start the application set up
    mkdir ${projectName}
    cd ${projectName}
    ddev config --project-type php --http-port 8000
    sleep 3
    ddev composer create drupal-composer/drupal-project:8.x-dev --prefer-dist
    sleep 3
    ddev config --project-type drupal8
    sleep 3
    ddev start
    sleep 3
    cd web/themes
    mkdir contrib custom
    cd contrib
    git clone https://github.com/drupalprojects/bootstrap.git
    sleep 3
    printf "${GREEN}\nDrupal Theme Name: ${themeName}${END}\n"
    printf "${GREEN}\nDrupal Theme Title: ${themeTitle}${END}\n"
    cp -R bootstrap/starterkits/sass ../custom/${themeName}
    cd ../custom/${themeName}
    mv THEMENAME.libraries.yml ${themeName}.libraries.yml
    mv THEMENAME.starterkit.yml ${themeName}.info.yml
    mv THEMENAME.theme ${themeName}.theme
    mv config/install/THEMENAME.settings.yml config/install/${themeName}.settings.yml
    mv config/schema/THEMENAME.schema.yml config/schema/${themeName}.schema.yml
    sleep 3
    sed -i.bak -e "s/THEMENAME/${themeName}/g;s/THEMETITLE/${themeTitle}/g" ${themeName}.info.yml
    sed -i.bak -e "s/THEMENAME/${themeName}/g;s/THEMETITLE/${themeTitle}/g" config/schema/${themeName}.schema.yml
    printf "${GREEN}\nGreat, we're all done here. Happy coding!\n\n${END}"
fi;
