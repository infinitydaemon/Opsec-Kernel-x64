// A simple C program for CWD Automated Builds
// Controbutions are welcome :)
// Build as gcc -o automate automate.c -lncurses
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ncurses.h>

// Function to execute a shell command and show output
int execute_command(const char *command, const char *title) {
    char log_file[] = "/tmp/cwd_systems_log.txt";
    char buffer[256];
    snprintf(buffer, sizeof(buffer), "%s > %s 2>&1", command, log_file);

    // Execute the command
    int status = system(buffer);

    // If the command fails, show the log
    if (status != 0) {
        clear();
        mvprintw(1, 1, "%s failed. Showing log:", title);
        refresh();
        
        FILE *log = fopen(log_file, "r");
        if (log) {
            int row = 3;
            while (fgets(buffer, sizeof(buffer), log)) {
                mvprintw(row++, 1, "%s", buffer);
                if (row >= LINES - 2) {
                    mvprintw(row, 1, "Press any key to continue...");
                    refresh();
                    getch();
                    clear();
                    row = 3;
                }
            }
            fclose(log);
        } else {
            mvprintw(3, 1, "Error: Unable to read log file.");
        }
        mvprintw(LINES - 2, 1, "Press any key to return to the menu...");
        refresh();
        getch();
    }
    return status;
}

// Function to detect the Linux distribution
void detect_distribution(char *dist, size_t len) {
    FILE *os_release = fopen("/etc/os-release", "r");
    if (os_release) {
        char line[256];
        while (fgets(line, sizeof(line), os_release)) {
            if (strncmp(line, "PRETTY_NAME=", 12) == 0) {
                strncpy(dist, strchr(line, '=') + 2, len);
                dist[strlen(dist) - 2] = '\0'; // Remove trailing quotes
                break;
            }
        }
        fclose(os_release);
    } else {
        strncpy(dist, "Unknown", len);
    }
}

// Main menu
void show_menu() {
    char choice;
    char distro[256] = "Unknown";

    detect_distribution(distro, sizeof(distro));

    initscr();
    noecho();
    cbreak();

    while (1) {
        clear();
        mvprintw(1, 1, "CWD SYSTEMS Automated Build System");
        mvprintw(3, 1, "Detected Linux Distribution: %s", distro);
        mvprintw(5, 1, "1. Build and install The Crawling Serpent Kernel");
        mvprintw(6, 1, "2. Harden TCP/IP stack and apply security settings");
        mvprintw(7, 1, "3. Enable ZerOS branding and update files");
        mvprintw(8, 1, "4. Update motd file");
        mvprintw(9, 1, "5. Exit");
        mvprintw(11, 1, "Choose an option: ");
        refresh();

        choice = getch();

        switch (choice) {
            case '1':
                execute_command("./build-server.sh", "Build and Install Kernel");
                break;
            case '2':
                execute_command("./stage2-hardening.sh", "Harden TCP/IP Stack");
                break;
            case '3':
                execute_command("./update-issue.sh", "Enable ZerOS Branding");
                break;
            case '4':
                execute_command("./update-motd.sh", "Update MOTD File");
                break;
            case '5':
                endwin();
                printf("Exiting... Goodbye!\n");
                return;
            default:
                mvprintw(13, 1, "Invalid option. Try again...");
                refresh();
                sleep(2);
                break;
        }
    }
}

int main() {
    show_menu();
    return 0;
}
