# #!/usr/bin/env zsh

case $1 in
stopall | sa)
  clpr blue "Going to stop all running containers"

  local running_containers=$(docker ps -q)

  running_containers=$(string trim $running_containers)

  if [[ $running_containers = '' ]]; then
    clpr green "No containers running"
  else
    clpr blue "Running 'docker stop \$(docker ps -a -q)'"
    docker stop $(docker ps -q)
  fi
  ;;
rmall | ra)
  clpr blue "Going to remove all containers available"
  clpr blue "Running 'docker rm \$(docker ps -a -q)'"
  docker rm $(docker ps -a -q)
  ;;
ps)
  docker ps
  ;;
psa)
  docker ps -a
  ;;
elci) # Exec Latest Container Interactive
  clpr blue "Going to list the latest launched docker image:"
  clpr blue "Running 'docker ps | head -n 2'"

  docker ps | head -n 2
  # If there are no containers, abort
  local linecount
  linecount=$(docker ps | wc -l)
  if [[ $linecount -lt 2 ]]; then
    clpr red "No container running. Cannot exec the latest container"
    return 3
  fi

  # Get the first from the list
  local selectedcontainer
  selectedcontainer=$(docker ps | head -n 2 | awk 'NR> 1 {print $1}' | xargs)
  clpr red "Are you sure you want to exec container ${selectedcontainer}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    clpr blue "What program would you like to run?"
    read program_to_run
    clpr blue "Running 'docker exec -it ${selectedcontainer} ${program_to_run}'"
    docker exec -it ${selectedcontainer} ${program_to_run}
    return 0
  else
    clpr default ""
    clpr blue "You opted for not exec'ing the container."
    clpr blue "!!! Aborting !!!"
    return 4
  fi
  ;;
rmlatest | rml)
  clpr blue "Going to list the latest image":
  clpr blue "Running 'docker images \$(docker ps -a -q)'"
  docker images | head -n 2
  local selectedimage
  selectedimage=$(docker images | head -n 2 | awk 'NR> 1 {print $3}' | xargs)
  clpr red "Are you sure you want to delete image ${selectedimage}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    clpr blue "You selected $choice"
    clpr red "Deleting image. Running 'docker rmi ${selectedimage}'"
    docker rmi $selectedimage
    clpr green "...done"
  else
    clpr default ""
    clpr blue "You opted for not deleting the image."
    clpr blue "!!! Aborting !!!"
    return 1
  fi
  ;;
sra)
  clpr blue "Going to delete and remove all containers available"
  clpr blue "Checking if there are any running containers"

  local available_containers=$(docker ps -a -q)

  available_containers=$(string trim $available_containers)

  if [[ $available_containers = '' ]]; then
    clpr green "No (running or stopped) containers are available to stop."
  else
    available_container_count=$(echo $available_containers | wc -w)
    clpr blue "There are ${available_container_count} containers available for deletion"

    clpr blue "Running 'docker stop \$(docker ps -a -q) && docker rm \$(docker ps -a -q)'"
    clpr blue "stopping..."
    docker stop $(docker ps -a -q)
    clpr blue "removing..."
    docker rm $(docker ps -a -q)
    clpr blue "...done"
  fi
  ;;
i)
  clpr blue "Listing images"
  clpr blue "Running 'docker images'"
  docker images
  ;;
li)
  clpr blue "Listing the latest image"
  clpr blue "Running 'docker images | head -n 2'"
  docker images | head -n 2
  ;;
rlii) # RunLatestImageInteractive
  clpr blue "Listing the latest image"
  docker images | head -n 2
  local selectedimage
  selectedimage=$(docker images | head -n 2 | awk 'NR> 1 {print $3}' | xargs)
  clpr red "Are you sure you want to run image ${selectedimage}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    clpr blue "You selected $choice"
    clpr red "Attempting. Running 'docker run -it ${selectedimage} sh'"
    docker run -it $selectedimage sh
    clpr green "...done"
  else
    clpr default ""
    clpr blue "You opted to not run the image."
    clpr blue "!!! Aborting !!!"
    return 2
  fi
  ;;
help)
  source ${0:A:h}/help.zsh dkr
  ;;
*)
  if [ $# -ne 0 ]; then
    clpr red "Unrecognized command. Run '${0} help' to get help"
    clpr blue "Running 'docker $*'"
    docker $*
  else
    source ${0:A:h}/help.zsh dkr
  fi
  ;;
esac
