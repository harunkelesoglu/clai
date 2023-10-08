#!/bin/bash

# Function to display an error message and exit
function throw_error() {
    echo "Error: $1"
    exit 1
}

# Function to validate the OpenAI model
function validateModel() {
    case "$OPENAI_MODEL" in
        "gpt-3.5-turbo")
            echo "Using the gpt-3.5-turbo model."
            ;;
        "gpt-4.0")
            echo "Using the gpt-4.0 model."
            ;;
        *)
            throw_error "Invalid OPENAI_MODEL value"
            ;;
    esac
}

# Function to make an API call and retrieve the response
function ask() {
    local message="$1"
    local response
    response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d '{
            "model": "'"$OPENAI_MODEL"'",
            "messages": [{"role": "user", "content": "'"$message"'"}],
            "temperature": 0.7
        }')

    echo "$response" | jq -r '.choices[0].message.content'
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    throw_error "jq is not installed. Please install it before running this script."$'\n'"On Ubuntu/Debian: sudo apt-get install jq"$'\n'"On CentOS/RHEL: sudo yum install jq"$'\n'"On macOS (Homebrew): brew install jq"
fi

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    throw_error "OPENAI_API_KEY should have been set in your bash profile (~/.zshrc, ~/.zprofile, ~/.bashrc, ~/.bash_profile)"
fi

# Check if OPENAI_MODEL is set
if [ -z "$OPENAI_MODEL" ]; then
    throw_error "OPENAI_MODEL should have been set in your bash profile (~/.zshrc, ~/.zprofile, ~/.bashrc, ~/.bash_profile)"
fi

# Validate the model and make the API call
validateModel
ask "$1"
