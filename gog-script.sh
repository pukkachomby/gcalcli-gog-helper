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
    echo "        GOG WORKSPACE MANAGER             "
    echo "=========================================="
    echo ""

    main_choice=$(gum choose \
        "Manage Tasks" \
        "Manage Calendar" \
        "Quit")

    case "$main_choice" in
        "Manage Tasks")
            while true; do
                clear
                echo "=========================================="
                echo "            TASK MANAGER                  "
                echo "=========================================="
                echo ""

                task_choice=$(gum choose \
                    "List Tasks" \
                    "Add a New Task" \
                    "Update a Task" \
                    "Delete a Task" \
                    "Back to Main Menu")

                case "$task_choice" in
                    "List Tasks")
                        clear
                        echo "Fetching tasks..."
                        echo "------------------------------------------"
                        gog task list "$LIST_ID"
                        echo ""
                        read -p "Press Enter to continue..."
                        ;;

                    "Add a New Task")
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

                    "Update a Task")
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

                            new_title=$(gum input --placeholder "Enter new task title...")
                            if [ -n "$new_title" ]; then
                                echo "Updating task ID: $task_id..."
                                gog task update "$LIST_ID" "$task_id" --title "$new_title"
                            else
                                gum style --foreground 208 "Cancelled: No title entered."
                                sleep 1
                            fi
                        else
                            gum style --foreground 208 "Cancelled: No task selected."
                            sleep 1
                        fi
                        ;;

                    "Delete a Task")
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

                    "Back to Main Menu"|*)
                        break
                        ;;
                esac
            done
            ;;

        "Manage Calendar")
            while true; do
                clear
                echo "=========================================="
                echo "           CALENDAR MANAGER               "
                echo "=========================================="
                echo ""

                cal_choice=$(gum choose \
                    "Agenda" \
                    "Month View (Monday)" \
                    "Week View (Monday)" \
                    "List Calendars" \
                    "List Events" \
                    "Create Event" \
                    "Delete Event" \
                    "Back to Main Menu")

                case "$cal_choice" in
                    "Agenda")
                        clear
                        echo "Loading calendar agenda..."
                        echo "------------------------------------------"
                        gcalcli agenda
                        echo ""
                        read -p "Press Enter to continue..."
                        ;;

                    "Month View (Monday)")
                        clear
                        echo "Loading monthly calendar..."
                        echo "------------------------------------------"
                        gcalcli calm --monday
                        echo ""
                        read -p "Press Enter to continue..."
                        ;;

                    "Week View (Monday)")
                        clear
                        echo "Loading weekly calendar..."
                        echo "------------------------------------------"
                        gcalcli calw --monday
                        echo ""
                        read -p "Press Enter to continue..."
                        ;;

                    "List Calendars")
                        clear
                        echo "Fetching calendars..."
                        echo "------------------------------------------"
                        gog calendar calendars
                        echo ""
                        read -p "Press Enter to continue..."
                        ;;

                    "List Events")
                        clear
                        echo "Fetching calendars to select from..."
                        echo "------------------------------------------"

                        cal_list_output=$(gog calendar calendars)
                        selected_cal=$(echo "$cal_list_output" | gum choose)

                        if [ -n "$selected_cal" ]; then
                            cal_id=$(echo "$selected_cal" | awk '{print $1}')
                            clear
                            echo "Fetching events for calendar: $cal_id"
                            echo "------------------------------------------"
                            gog calendar events "$cal_id"
                            echo ""
                            read -p "Press Enter to continue..."
                        else
                            gum style --foreground 208 "Cancelled: No calendar selected."
                            sleep 1
                        fi
                        ;;

                    "Create Event")
                        clear
                        echo "Fetching calendars to select from..."
                        echo "------------------------------------------"

                        cal_list_output=$(gog calendar calendars)
                        selected_cal=$(echo "$cal_list_output" | gum choose)

                        if [ -n "$selected_cal" ]; then
                            cal_id=$(echo "$selected_cal" | awk '{print $1}')
                            summary=$(gum input --placeholder "Enter event summary/title...")
                            from_time=$(gum input --placeholder "Start time (RFC3339, e.g. 2026-11-08T10:00:00Z)...")
                            to_time=$(gum input --placeholder "End time (RFC3339, e.g. 2026-11-08T11:00:00Z)...")

                            if [ -n "$summary" ] && [ -n "$from_time" ] && [ -n "$to_time" ]; then
                                echo "Creating event..."
                                gog calendar create "$cal_id" --summary "$summary" --from "$from_time" --to "$to_time"
                            else
                                gum style --foreground 208 "Cancelled: Missing required fields."
                                sleep 1
                            fi
                        else
                            gum style --foreground 208 "Cancelled: No calendar selected."
                            sleep 1
                        fi
                        ;;

                    "Delete Event")
                        clear
                        echo "Fetching calendars to select from..."
                        echo "------------------------------------------"

                        cal_list_output=$(gog calendar calendars)
                        selected_cal=$(echo "$cal_list_output" | gum choose)

                        if [ -n "$selected_cal" ]; then
                            cal_id=$(echo "$selected_cal" | awk '{print $1}')
                            clear
                            echo "Fetching events to select from..."
                            echo "------------------------------------------"

                            event_list_output=$(gog calendar events "$cal_id")
                            if [ -z "$event_list_output" ]; then
                                echo "No events found in this calendar."
                                sleep 1
                                continue
                            fi

                            selected_event=$(echo "$event_list_output" | gum choose)

                            if [ -n "$selected_event" ]; then
                                event_id=$(echo "$selected_event" | awk '{print $1}')
                                echo "Deleting event ID: $event_id..."
                                gog calendar delete "$cal_id" "$event_id"
                            else
                                gum style --foreground 208 "Cancelled: No event selected."
                                sleep 1
                            fi
                        else
                            gum style --foreground 208 "Cancelled: No calendar selected."
                            sleep 1
                        fi
                        ;;

                    "Back to Main Menu"|*)
                        break
                        ;;
                esac
            done
            ;;

        "Quit"|*)
            clear
            echo "Exiting."
            exit 0
            ;;
    esac
done
