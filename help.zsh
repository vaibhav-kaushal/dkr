#!/usr/bin/env zsh

pr blue "The following commands are available:"
pr default "${1} ps                   List running containers (docker ps)"
pr default "${1} psa                  Lists all containers (docker ps -a)"
pr default "${1} stopall (sa)         Stops all running containers"
pr default "${1} rmall (ra)           Deletes all containers"
pr default "${1} sra                  Stops and then Deletes all containers"
pr default "${1} i                    Shows the images in docker"
pr default "${1} li                   Shows the latest image created"
pr default "${1} rmlatest (rml)       Shows the latest image created and asks if you want to delete it"
pr default "${1} rlii)                Shows the latest image created and asks if you want to run it"
pr default "${1} elci)                Exec Latest-Launched Container in Interactive mode"
pr default ""
pr blue "Run '${1} help' to get this help."
pr blue "Running ${1} <command> where command is not in the above list will run 'docker <command>'."
pr blue "    e.g. '${0} --help' will run 'docker --help'"
