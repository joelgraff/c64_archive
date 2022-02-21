#!/bin/bash
exit_program="n"
disk_side="A"
image_name="."
counter=0

disk_change () {
	echo -e "\n\nInsert disk (Side "$disk_side")"
	cbmctrl change 8
}

get_dir () {

	if cbmctrl dir 8 | tee -a "dir.tmp" | grep "read error"; then
		return -1
	fi

	if cbmctrl dir 8 | tee -a "dir.tmp" | grep "drive not ready"; then
		return -1
	fi

	return 0
}

make_path () {

	image_name="."

	until [ ! -d ./$image_name ]
	do
		echo -e "\n\n"
		read -p "Enter image name: " image_name

		if [ -d ./$image_name ]; then

			echo -e "\n"
			read -p "Directory exists.  Overwrite? (y/n)" overwrite

			if [ $overwrite == "y" ]; then
				rm -rf ./$image_name
			fi
		fi
	done

	mkdir ./$image_name
}

make_image () {

	d64copy 8 ./image.d64
	((counter=counter+1))
}

finalize () {

	make_path

	filename=$image_name\_$disk_side

	mv dir.tmp ./$image_name/$filename.dir
	mv image.d64 ./$image_name/$filename.d64
}

main () {

	echo -e "\n\nInsert a disk and press a key to begin..."

	while [ $exit_program == "n" ]
	do
		read -n 1 user_input

		if [[ $user_input == "q" ]]; then
			exit
		fi

		get_dir

		if [ $? -eq 0 ]; then
			make_image
		fi

		user_input="r"

		while [[ $user_input == "r" ]]
		do

			echo -e "\n\n"
			read -n 1 -p "(s)ave, (r)etry, (a)bort? " user_input

			if [[ $user_input == "s" ]]; then
				finalize
			elif [[ $user_input == "r" ]]; then
				make_image
			fi
		done

		if [[ $counter -gt 9 && $disk_side == "B" ]]; then
			echo -e" \n\nINSERT DISK CLEANER AND PRESS A KEY"
			cbmctrl dir 8
		fi

		if [ $disk_side == "A" ]; then
			disk_side="B"
			echo -e "\n\nFlip disk and press a key (q to quit)..."
		else
			disk_side="A"
			echo -e "\n\nInsert next disk and press a key (q to quit)..."
		fi

	done
}

clear

main
