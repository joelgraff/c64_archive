es#!/bin/bash
exit_program="n"
disk_side="A"
image_name="."

disk_change () {
	echo -e "\n\nInsert disk (Side "$disk_side")"
	cbmctrl change 8
}

get_dir () {

	if cbmctrl dir 8 | tee -a "dir.log" | grep "read error"; then
		echo -e "\n\nDisk Error"
		return -1
	fi

	return 0
}

make_path () {

	image_name="."

	until [ ! -d ./$image_name ]
	do
		read -p "Enter image name:" image_name

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

	filename=$image_name\_$disk_side

	cbmctrl dir 8 >> ./$image_name/$filename.dir
	d64copy 8 ./$image_name/$filename.d64
}

main () {

	while [ $exit_program == "n" ]
	do
		echo -e "\n\nInsert disk side" $disk_side "and press a key (q to quit)..."
		read -n 1 user_input

		if [[ $user_input = "q" ]]; then
			exit
		fi

		if [ $disk_side == "A" ]; then
			get_dir

			if [ $? -eq 0 ]; then
				make_path
			fi
		fi

		make_image

		if [ $disk_side == "A" ]; then
			disk_side="B"
		else
			disk_side="A"
		fi
	done
}

clear

main
