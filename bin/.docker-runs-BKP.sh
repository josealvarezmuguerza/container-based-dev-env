#!/bin/bash
# Bash wrappers for docker run commands
# run 'source .docker-runs'  every time this file be updated or restart the terminal
# for saving a new running container as image `docker commit deddd39fa163 ubuntu-nmap`

del_stopped(){
	local name=$1
        local user=$(if [[  $2 == "as_root" ]]; then echo "sudo "; fi)

	local state
	state=$($user podman inspect --format "{{.State.Running}}" " $name" 2>/dev/null)
	
	if [[ "$state" != "false" ]]; then
		echo "There is " $name " container already in running state. Stop it?"
		#$user podman rm "$name"
		#echo "Done!"
	fi
	
	state=$($user podman inspect --format "{{.State.Stop}}" " $name" 2>/dev/null)
	
	if [[ "$state" != "false" ]]; then
		echo "Existing abandoned " $name " container. Removing..."
		$user podman rm "$name"
		echo "Done!"
	fi
}


aws(){
	container_name=${FUNCNAME[0]}
	podman run -it --rm \
		-v ${HOME}/workspace:/root/workspace/ \
		-v ${HOME}/.aws:/root/.aws \
		-v ${HOME}/.ssh:/root/.ssh \	
		--name ${container_name} \
		jess/awscli "$@"
}

mattermost(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}

	podman run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/snd \
		--device /dev/dri \
		--device /dev/video0 \
		--group-add audio \
		--group-add video \
              	-v "${HOME}/Downloads:/root/mattermost" \
		--ipc="host" \
		--name ${container_name} \
		jose/mattermost "$@"
}
# export your KUBECONFIG first
# export KUBECONFIG=${HOME}/.kube/config
kubectl(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}

      	podman run --rm \
      		-v ${KUBECONFIG}:/.kube/config \
		-v ${HOME}/workspace:/root/workspace/ \
		-v ${HOME}/.aws:/root/.aws \
		-v ${HOME}/.ssh:/root/.ssh \
      		--name ${container_name} \
      		bitnami/kubectl:latest "$@"
}

# this skyscrapers/kops image contains 'aws', 'kubectl' and 'kops'
# export KUBECONFIG=~/.kube/config-aws-kops 
# kops uses a custom script to start/edit/stop cluster over a kops docker image. Thanks https://gitlab.com/frankmb/kops-starter
kops_starter(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}
	
	podman run -i --rm \
	-v ${KUBECONFIG}:/.kube/config \
	-v ${HOME}/workspace/kops-starter/:/root/ \
	-v ${HOME}/.aws:/root/.aws \
	-v ${HOME}/.ssh:/root/.ssh \
	--entrypoint "/bin/sh" \
	--name ${container_name} \
	skyscrapers/kops:latest \
	/root/start.sh 
}

# k3s uses a shared script to start/stop/reset/getkc k3s cluster. Thanks to Juan de la Cámara: https://gitlab.com/tooling2/k3s-boot
k3s(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}

#// kung fu
	podman run -d --rm \
	    -v $(pwd):/output \
	    -v /:/rootfs:ro \
	    -v /sys:/sys:ro \
	    -v /var/run:/var/run:rw \
	    -v /var/lib/docker/:/var/lib/docker \
	    -e K3S_CLUSTER_SECRET=somethingtotallyrandom  \
	    -e K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml \
	    -e K3S_KUBECONFIG_MODE=666 \
	    -p 6443:6443 \
	    --privileged \
	    rancher/k3s server 
# --podman


#	podman run -i --rm \
#	-v $KUBECONFIG:/.kube/config \
#	-v $HOME/workspace:/root/workspace/ \
#	-v $HOME/workspace/k3s-boot/:/root/ \
#	-v $HOME/.aws:/root/.aws \
#	-v $HOME/.ssh:/root/.ssh \
#	--entrypoint "/bin/sh" \
#	--name k3s \
#	rancher/k3s \
#	/root/k3s-boot.sh "$@"
}

# zoom calls can be open by simply 'xdg-open https://xxxxx.zoom.us/j/xxxxxxxx?pwd=1234' . However if you need to host a session, run the GUI
zoom(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman run -d --rm \
	 	-v /tmp/.X11-unix:/tmp/.X11-unix \
	 	-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/video0 \
		--device /dev/snd:/dev/snd \
		--device /dev/dri \
		-v /dev/shm:/dev/shm \
		--name ${container_name} \
		zoom
}

# works as root
spotify(){
	container_name=${FUNCNAME[0]}
	del_stopped $container_name as_root
	
	podman run -d \
		-v /etc/localtime:/etc/localtime:ro \
	 	-v /tmp/.X11-unix:/tmp/.X11-unix \
	 	-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/video0 \
		--device /dev/snd:/dev/snd \
		--device /dev/dri \
		-v /dev/shm:/dev/shm \
		--name ${container_name} \
		jess/spotify 

}

# dev env Java, maven, node , yarn
dev(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}	
	echo "Launching " $name " - Ubuntu 20.04 LTS - Openjdk 14.0.1 - Apache Maven 3.6.3 - Git - node"

	podman run -it --rm \
		-v $(pwd)/workspace:/root/workspace \
		-v $(pwd)/workspace-sandbox:/root/workspace-sandbox \
		-v $(pwd)/tools:/root/tools \
		-v $(pwd)/.m2/:/root/.m2/ \
     		-v /tmp/.X11-unix:/tmp/.X11-unix \
	 	-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/video0 \
		-p 8080:8080 \
		-p 9000:9000 \
		-p 9001:9001 \
		-p 9999:9999 \
    	        -p 3000:3000 \
		--net=host \
   	        --name ${container_name} \
		-w /root/workspace \
 		--entrypoint bash \
 		-u root \
		--name  ${container_name} \
		localhost/dev
}

office(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}
 	
	podman run -d --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=unix$DISPLAY \
		-v $HOME/Dropbox:/root/Dropbox \
		-v $HOME/Documents:/root/Documents \
		-v $HOME/Downloads:/root/Downloads \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name ${container_name} \
		jess/libreoffice

}


node-custom(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman run --rm -it \
		-v ${HOME}/workspace/:/root/ \
		-v $HOME/Downloads:/root/Downloads \
		-v $HOME/tools:/root/tools \
		-p 3000:3000 \
		--name ${container_name} \
 		--entrypoint bash \
		node-custom
}


swagger(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman run --rm -d \
		-v ${HOME}/workspace/:/root/ \
		-p 1080:8080 \
		--name ${container_name} \
		swaggerapi/swagger-editor
}

#podman exec -it timescaledb psql -U postgres
timescaledb(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}
 	
	podman run -d --rm \
		--name timescaledb \
		-p 5432:5432 \
		--net=host \
		-e POSTGRES_PASSWORD=s3cr3t \
		-v $HOME/tools/timescaledb/data:/var/lib/postgresql/data \
 		timescale/timescaledb:latest-pg12
 		
}

# sudo podman network inspect podman
pgadmin(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name} as_root

	sudo podman run --rm \
		-p 8080:80 \
		-e PGADMIN_DEFAULT_EMAIL="postgres" \
		-e PGADMIN_DEFAULT_PASSWORD="s3cr3t" \
		-v $HOME/tools/timescaledb/data:/var/lib/postgresql/data \
		 dpage/pgadmin4


}

psql(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman exec -it \
		timescaledb psql -U postgres 
}

hapi(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name} as_root

	sudo podman run -it \
		-p 8080:8080 \
		smartonfhir/hapi-5:r4-synthea
}  

# for errors like Unable to load authentication plugin 'caching_sha2_password'. Do: 
# open new console: 
#podman run -it --network host --rm mysql mysql -h127.0.0.1 -uroot -p
#ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'pass';
mysqld(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman run \
	  --name ${container_name} \
	  --net host \
          -p 8080:8080 \
          -p 3306:3306 \
          -e MYSQL_ROOT_PASSWORD=pass \
	  -d mysql:latest
}


dbeaver(){
	container_name=${FUNCNAME[0]}
 	del_stopped ${container_name}

	podman run -it \
	  -e DISPLAY=unix$DISPLAY \
	  -e GDK_DPI_SCALE \
	  -e GDK_SCALE \
	  --name ${container_name} \
	  -v $HOME/.dbeaver-drivers/:/root/.dbeaver-drivers \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
  	  --net host \
  	  jainishshah17/docker-dbeaver dbeaver

}

  
$1
