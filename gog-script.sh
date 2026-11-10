#!/usr/bin/env bash

set -e

LIST_ID="MTM1OTc5MzY2MTEyODI5MzU0MTQ6MDow"

if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is not installed. Run 'brew install gum' first."
    exit 1
fi

while true; do
    clear
    echo "=========================================="
    echo "        GOG + GCALCLI HELPER              "
    echo "=========================================="
    echo ""

    main_choice=$(gum choose \
        "Task: List" \
        "Task: Add" \
        "Task: Remove" \
        "Calendar") || exit 0

    case "$main_choice" in
        "Task: List")
            clear
            echo "Fetching tasks..."
            echo "------------------------------------------"
            gog task list "$LIST_ID"
            echo ""
            read -p "Press Enter to continue..."
            ;;

        "Task: Add")
            clear
            task_title=$(gum input --placeholder "Enter task title...")

            if [ -n "$task_title" ]; then
                echo ""
                echo "Adding task..."
                gog task add "$LIST_ID" --title "$task_title"
            else
                gum style --foreground 208 "Cancelled: No title entered."
                sleep 1
            fi
            ;;

        "Task: Remove")
            clear
            echo "Fetching task list to select from..."
            echo "------------------------------------------"

            task_list_output=$(gog task list "$LIST_ID")
            if [ -z "$task_list_output" ]; then
                echo "No tasks found."
                sleep 1
                continue
            fi

            selected_task=$(echo "$task_list_output" | gum choose)

            if [ -n "$selected_task" ]; then
                task_id=$(echo "$selected_task" | awk '{print $1}')
                echo "Deleting task ID: $task_id..."
                gog task delete "$LIST_ID" "$task_id"
            else
                gum style --foreground 208 "Cancelled: No task selected."
                sleep 1
            fi
            ;;

        "Calendar")
            clear
            echo "Loading monthly calendar..."
            echo "------------------------------------------"
            gcalcli calm --monday
            echo ""
            read -p "Press Enter to continue..."
            ;;
    esac
done
