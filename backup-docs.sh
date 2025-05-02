#!/bin/bash

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DOCS_HOME="$HOME/.docs/documentation"
BACKUP_DIR="$DOCS_HOME/backups"
DATE_FORMAT=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/documentation_backup_$DATE_FORMAT.zip"

# Function to display help
show_help() {
    echo "Documentation App Backup/Restore Utility"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -b, --backup   Create a backup (default action)"
    echo "  -r, --restore  Restore from a backup"
    echo "  -l, --list     List available backups"
    echo "  -p, --path     Specify a custom backup path"
    echo ""
    echo "Examples:"
    echo "  $0                     # Create a backup with default settings"
    echo "  $0 -r                  # Restore (will prompt for backup file)"
    echo "  $0 -r -p /path/to/file # Restore from specific backup file"
    echo "  $0 -l                  # List available backups"
}

# Function to create a backup
create_backup() {
    echo -e "${BLUE}=== Creating Documentation Backup ===${NC}"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Check if the database exists
    if [ ! -f "$DOCS_HOME/db.mv.db" ]; then
        echo -e "${RED}No database found at $DOCS_HOME/db.mv.db${NC}"
        echo -e "${YELLOW}Have you run the application at least once?${NC}"
        exit 1
    fi
    
    # Stop any running instances of the application
    echo -e "${YELLOW}Ensuring no application instances are running...${NC}"
    if command -v docker &> /dev/null; then
        docker ps | grep documentation-app > /dev/null && docker stop documentation-app
    fi
    
    # Create backup
    echo -e "${GREEN}Creating backup to $BACKUP_FILE...${NC}"
    zip -j "$BACKUP_FILE" "$DOCS_HOME"/db*
    
    echo -e "${GREEN}Backup completed successfully!${NC}"
    echo -e "${BLUE}Backup saved to:${NC} $BACKUP_FILE"
}

# Function to restore from a backup
restore_backup() {
    echo -e "${BLUE}=== Restoring Documentation from Backup ===${NC}"
    
    # If no path is specified, list backups and prompt for selection
    if [ -z "$CUSTOM_PATH" ]; then
        if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
            echo -e "${RED}No backups found in $BACKUP_DIR${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}Available backups:${NC}"
        local i=1
        local backups=()
        
        while IFS= read -r file; do
            echo "  $i. $(basename "$file")"
            backups+=("$file")
            ((i++))
        done < <(find "$BACKUP_DIR" -name "*.zip" | sort -r)
        
        echo ""
        read -p "Enter backup number to restore: " selection
        
        if [[ ! "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#backups[@]}" ]; then
            echo -e "${RED}Invalid selection${NC}"
            exit 1
        fi
        
        BACKUP_FILE="${backups[$((selection-1))]}"
    else
        BACKUP_FILE="$CUSTOM_PATH"
        
        if [ ! -f "$BACKUP_FILE" ]; then
            echo -e "${RED}Backup file not found: $BACKUP_FILE${NC}"
            exit 1
        fi
    fi
    
    # Stop any running instances of the application
    echo -e "${YELLOW}Ensuring no application instances are running...${NC}"
    if command -v docker &> /dev/null; then
        docker ps | grep documentation-app > /dev/null && docker stop documentation-app
    fi
    
    # Backup current database before restoring
    if [ -f "$DOCS_HOME/db.mv.db" ]; then
        echo -e "${YELLOW}Creating backup of current database before restoring...${NC}"
        TEMP_BACKUP="$BACKUP_DIR/pre_restore_backup_$DATE_FORMAT.zip"
        zip -j "$TEMP_BACKUP" "$DOCS_HOME"/db*
        echo -e "${GREEN}Current database backed up to $TEMP_BACKUP${NC}"
    fi
    
    # Remove current database files
    echo -e "${YELLOW}Removing current database files...${NC}"
    rm -f "$DOCS_HOME"/db*
    
    # Extract backup
    echo -e "${GREEN}Restoring from $BACKUP_FILE...${NC}"
    unzip -o "$BACKUP_FILE" -d "$DOCS_HOME"
    
    echo -e "${GREEN}Restore completed successfully!${NC}"
}

# Function to list available backups
list_backups() {
    echo -e "${BLUE}=== Available Documentation Backups ===${NC}"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        echo -e "${YELLOW}No backups found in $BACKUP_DIR${NC}"
        return
    fi
    
    echo -e "${GREEN}Backup directory:${NC} $BACKUP_DIR"
    echo ""
    
    echo -e "${GREEN}Available backups:${NC}"
    find "$BACKUP_DIR" -name "*.zip" -type f | sort -r | while read -r backup; do
        size=$(du -h "$backup" | cut -f1)
        date=$(date -r "$backup" "+%Y-%m-%d %H:%M:%S")
        echo "  $(basename "$backup") (${size}, created: ${date})"
    done
}

# Parse command line arguments
ACTION="backup"
CUSTOM_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -b|--backup)
            ACTION="backup"
            shift
            ;;
        -r|--restore)
            ACTION="restore"
            shift
            ;;
        -l|--list)
            ACTION="list"
            shift
            ;;
        -p|--path)
            if [[ -n "$2" && "$2" != -* ]]; then
                CUSTOM_PATH="$2"
                shift 2
            else
                echo -e "${RED}Error: Argument for $1 is missing${NC}" >&2
                exit 1
            fi
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done

# Execute the specified action
case $ACTION in
    backup)
        create_backup
        ;;
    restore)
        restore_backup
        ;;
    list)
        list_backups
        ;;
esac
