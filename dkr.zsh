# #!/usr/bin/env zsh

case $1 in
stopall | sa)
  pr blue "Going to stop all running containers"

  local running_containers=$(docker ps -q)

  running_containers=$(string trim $running_containers)

  if [[ $running_containers = '' ]]; then
    pr green "No containers running"
  else
    pr blue "Running 'docker stop \$(docker ps -a -q)'"
    docker stop $(docker ps -q)
  fi
  ;;
rmall | ra)
  pr blue "Going to remove all containers available"
  pr blue "Running 'docker rm \$(docker ps -a -q)'"
  docker rm $(docker ps -a -q)
  ;;
ps)
  docker ps
  ;;
psa)
  docker ps -a
  ;;
elci) # Exec Latest Container Interactive
  pr blue "Going to list the latest launched docker image:"
  pr blue "Running 'docker ps | head -n 2'"

  docker ps | head -n 2
  # If there are no containers, abort
  local linecount
  linecount=$(docker ps | wc -l)
  if [[ $linecount -lt 2 ]]; then
    pr red "No container running. Cannot exec the latest container"
    return 3
  fi

  # Get the first from the list
  local selectedcontainer
  selectedcontainer=$(docker ps | head -n 2 | awk 'NR> 1 {print $1}' | xargs)
  pr red "Are you sure you want to exec container ${selectedcontainer}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    pr blue "What program would you like to run?"
    read program_to_run
    pr blue "Running 'docker exec -it ${selectedcontainer} ${program_to_run}'"
    docker exec -it ${selectedcontainer} ${program_to_run}
    return 0
  else
    pr default ""
    pr blue "You opted for not exec'ing the container."
    pr blue "!!! Aborting !!!"
    return 4
  fi
  ;;
rmlatest | rml)
  pr blue "Going to list the latest image":
  pr blue "Running 'docker images \$(docker ps -a -q)'"
  docker images | head -n 2
  local selectedimage
  selectedimage=$(docker images | head -n 2 | awk 'NR> 1 {print $3}' | xargs)
  pr red "Are you sure you want to delete image ${selectedimage}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    pr blue "You selected $choice"
    pr red "Deleting image. Running 'docker rmi ${selectedimage}'"
    docker rmi $selectedimage
    pr green "...done"
  else
    pr default ""
    pr blue "You opted for not deleting the image."
    pr blue "!!! Aborting !!!"
    return 1
  fi
  ;;
sra)
  pr blue "Going to delete and remove all containers available"
  pr blue "Checking if there are any running containers"

  local available_containers=$(docker ps -a -q)

  available_containers=$(string trim $available_containers)

  if [[ $available_containers = '' ]]; then
    pr green "No (running or stopped) containers are available to stop."
  else
    available_container_count=$(echo $available_containers | wc -w)
    pr blue "There are ${available_container_count} containers available for deletion"

    pr blue "Running 'docker stop \$(docker ps -a -q) && docker rm \$(docker ps -a -q)'"
    pr blue "stopping..."
    docker stop $(docker ps -a -q)
    pr blue "removing..."
    docker rm $(docker ps -a -q)
    pr blue "...done"
  fi
  ;;
i)
  pr blue "Listing images"
  pr blue "Running 'docker images'"
  docker images
  ;;
li)
  pr blue "Listing the latest image"
  pr blue "Running 'docker images | head -n 2'"
  docker images | head -n 2
  ;;
rlii) # RunLatestImageInteractive
  pr blue "Listing the latest image"
  docker images | head -n 2
  local selectedimage
  selectedimage=$(docker images | head -n 2 | awk 'NR> 1 {print $3}' | xargs)
  pr red "Are you sure you want to run image ${selectedimage}? [y/n]"
  read -k1 choice
  if [[ $choice = "y" || $choice = "Y" ]]; then
    pr blue "You selected $choice"
    pr red "Attempting. Running 'docker run -it ${selectedimage} sh'"
    docker run -it $selectedimage sh
    pr green "...done"
  else
    pr default ""
    pr blue "You opted to not run the image."
    pr blue "!!! Aborting !!!"
    return 2
  fi
  ;;
help)
  source ${0:A:h}/help.zsh dkr
  ;;
*)
  if [ $# -ne 0 ]; then
    pr red "Unrecognized command. Run '${0} help' to get help"
    pr blue "Running 'docker $*'"
    docker $*
  else
    source ${0:A:h}/help.zsh dkr
  fi
  ;;
esac
