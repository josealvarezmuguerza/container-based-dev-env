#!/bin/bash
# Bash wrappers for docker run commands
# run 'source .docker-runs'  every time this file be updated 
# for saving a new running container as image `docker commit deddd39fa163 ubuntu-nmap`

setup(){
        
        if [[ "$superuser" == "true" ]]; then as_root="sudo"; else as_root=""; fi 

	running=$($user podman inspect --format "{{.State.Running}}" "$container_name" 2>/dev/null)		
	# check for running instance
	if [[ "$running" == "true" ]]; then
              echo "There is "$container_name" container already in running state. Let's re-use it! "
	else
		# remove abandoned instance
		stop=$($user podman inspect --format "{{.State.Stop}}" "$container_name" 2>/dev/null)	
		if [[ "$stop" != "false" ]]; then
			echo "Existing abandoned " $container_name " container. Removing..."
			$user podman rm "$container_name"
			echo "... archive removed!"
		fi
		# launch new instance
		echo "Launching new $container_name container..."
		$user $@
	fi
}



aws(){
	export container_name=${FUNCNAME[0]}
	aws_params=$@

	docker_command=$(echo "podman run -it --rm \
		-v ${HOME}/workspace:/root/workspace/ \
		-v ${HOME}/.aws:/root/.aws \
		-v ${HOME}/.ssh:/root/.ssh \	
		--name ${container_name} 
		jess/awscli "$aws_params)

	setup $docker_command
}

mattermost(){
	export container_name=${FUNCNAME[0]}
	mattermost_params=$@
	docker_command=$(echo "podman run -d \
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
		jose/mattermost "$mattermost_params)

	setup $docker_command	
}

# export your KUBECONFIG first
# export KUBECONFIG=${HOME}/.kube/config
kubectl(){
	export container_name=${FUNCNAME[0]}
	kubectl_params=$@
	docker_command=$(echo "podman run --rm \
      		-v ${KUBECONFIG}:/.kube/config \
		-v ${HOME}/workspace:/root/workspace/ \
		-v ${HOME}/.aws:/root/.aws \
		-v ${HOME}/.ssh:/root/.ssh \
      		--name ${container_name} \
      		bitnami/kubectl:latest "$kubectl_params)

	setup $docker_command	      	
}

# this skyscrapers/kops image contains 'aws', 'kubectl' and 'kops'
# export KUBECONFIG=~/.kube/config-aws-kops 
# kops uses a custom script to start/edit/stop cluster over a kops docker image. Thanks https://gitlab.com/frankmb/kops-starter
kops_starter(){
	export container_name=${FUNCNAME[0]}
	
	docker_command=$(echo "podman run -i --rm \
	-v ${KUBECONFIG}:/.kube/config \
	-v ${HOME}/workspace/kops-starter/:/root/ \
	-v ${HOME}/.aws:/root/.aws \
	-v ${HOME}/.ssh:/root/.ssh \
	--entrypoint "/bin/sh" \
	--name ${container_name} 
	skyscrapers/kops:latest \
	/root/start.sh ")

	setup $docker_command		
}

# k3s uses a shared script to start/stop/reset/getkc k3s cluster. Thanks to Juan de la Cámara(Kung fu): https://gitlab.com/tooling2/k3s-boot
k3s(){
	container_name=${FUNCNAME[0]}
	del_stopped ${container_name}

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
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run -d --rm \
	 	-v /tmp/.X11-unix:/tmp/.X11-unix \
	 	-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/video0 \
		--device /dev/snd:/dev/snd \
		--device /dev/dri \
		-v /dev/shm:/dev/shm \
		--name ${container_name} 
		zoom")

	setup $docker_command	
}

# works as root
spotify(){
	export container_name=${FUNCNAME[0]}
	export superuser=true
	
	docker_command=$(echo "podman run -d \
		-v /etc/localtime:/etc/localtime:ro \
	 	-v /tmp/.X11-unix:/tmp/.X11-unix \
	 	-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/video0 \
		--device /dev/snd:/dev/snd \
		--device /dev/dri \
		-v /dev/shm:/dev/shm \
		--name ${container_name} 
		jess/spotify")

	setup $docker_command		
}

# dev env Java, maven, node , yarn
dev(){
	export container_name=${FUNCNAME[0]}
	echo "Launching " $name " - Ubuntu 20.04 LTS - Openjdk 14.0.1 - Apache Maven 3.6.3 - Git - node"
	
	docker_command=$(echo "podman run -it --rm \
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
   	        --name ${container_name} 
		-w /root/workspace \
 		--entrypoint bash \
 		-u root \
		--name  ${container_name} \
		localhost/dev")

	setup $docker_command
}

office(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run -d --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e DISPLAY=unix$DISPLAY \
		-v $HOME/Dropbox:/root/Dropbox \
		-v $HOME/Documents:/root/Documents \
		-v $HOME/Downloads:/root/Downloads \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name ${container_name} 
		jess/libreoffice")


	setup $docker_command	
}


node-custom(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run --rm -it \
		-v ${HOME}/workspace/:/root/ \
		-v $HOME/Downloads:/root/Downloads \
		-v $HOME/tools:/root/tools \
		-p 3000:3000 \
		--name ${container_name} 
 		--entrypoint bash \
		node-custom")

	setup $docker_command	
}


swagger(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run --rm -d \
		-v ${HOME}/workspace/:/root/ \
		-p 1080:8080 \
		--name ${container_name} 
		swaggerapi/swagger-editor")

	setup $docker_command			
}

#podman exec -it timescaledb psql -U postgres
timescaledb(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run -d --rm \
	        --name ${container_name}  
		-p 5432:5432 \
		--net=host \
		-e POSTGRES_PASSWORD=s3cr3t \
		-v $HOME/tools/timescaledb/data:/var/lib/postgresql/data \
 		timescale/timescaledb:latest-pg12")

	setup $docker_command		
}

# sudo podman network inspect podman
pgadmin(){
	export container_name=${FUNCNAME[0]}
	export superuser=false
	docker_command=$(echo "podman run --rm \
	        --name ${container_name}  
		-p 8080:80 \
		-e PGADMIN_DEFAULT_EMAIL="postgres" \
		-e PGADMIN_DEFAULT_PASSWORD="s3cr3t" \
		-v $HOME/tools/timescaledb/data:/var/lib/postgresql/data \
		 dpage/pgadmin4") 

	setup $docker_command
}

psql(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run -it \
	          --name ${container_name}  
	          timescaledb psql -U postgres --net host ")

	setup $docker_command
}

hapi(){
	export container_name=${FUNCNAME[0]}
	export superuser=true
	
	docker_command=$(echo "podman run -it \
		-p 8080:8080 \
		smartonfhir/hapi-5:r4-synthea")

	setup $docker_command		
}  


# for errors like Unable to load authentication plugin 'caching_sha2_password'. Do: 
# open new console: 
#podman run -it --network host --rm mysql mysql -h127.0.0.1 -uroot -p
#ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'pass';
mysqld(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "podman run \
	          --name ${container_name}  
		  --net host \
		  -p 8080:8080 \
		  -p 3306:3306 \
		  -e MYSQL_ROOT_PASSWORD=pass \
		  -d mysql:latest")

	setup $docker_command
}


dbeaver(){
	export container_name=${FUNCNAME[0]}
	docker_command=$(echo "	podman run -it \
	  -e DISPLAY=unix$DISPLAY \
	  -e GDK_DPI_SCALE \
	  -e GDK_SCALE \
	  --name ${container_name} 
	  -v $HOME/.dbeaver-drivers/:/root/.dbeaver-drivers \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /tmp/.X11-unix:/tmp/.X11-unix \
  	  --net host \
  	  jainishshah17/docker-dbeaver dbeaver")

	setup $docker_command
}

$1
