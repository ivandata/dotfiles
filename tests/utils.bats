#!/usr/bin/env bats

# Load the script
load '../utils.sh'

# Test for print_in_red
@test "print_in_red outputs red text" {
    run print_in_red "Test message"
    [[ "$output" == $'\033[31mTest message\033[0m' ]]
}

# Test for print_in_green
@test "print_in_green outputs green text" {
    run print_in_green "Success"
    [[ "$output" == $'\033[32mSuccess\033[0m' ]]
}

# Test for print_in_yellow
@test "print_in_yellow outputs yellow text" {
    run print_in_yellow "Warning"
    [[ "$output" == $'\033[33mWarning\033[0m' ]]
}

# Test for command_exists (positive case)
@test "command_exists returns success for existing command" {
    run command_exists "bash"
    [[ "$status" -eq 0 ]]
}

# Test for command_exists (negative case)
@test "command_exists returns failure for non-existent command" {
    run command_exists "non_existent_command"
    [[ "$status" -ne 0 ]]
}

# Test for link
@test "link creates a symlink successfully" {
    mkdir -p /tmp/test_dir
    echo "test content" > /tmp/test_dir/test_file
    link "/tmp/test_dir" "test_file" "test_symlink"
    [[ -L "$HOME/test_symlink" ]]
    [[ "$(readlink "$HOME/test_symlink")" == "/tmp/test_dir/test_file" ]]
    rm -f "$HOME/test_symlink"
    rm -rf /tmp/test_dir
}

# Test for ask_question
@test "ask_question outputs prompt" {
    run ask_question "Do you want to proceed?"
    [[ "$output" =~ "Do you want to proceed?" ]]
}

# Test for is_confirmed
@test "is_confirmed returns success for 'y'" {
    REPLY="y"
    run is_confirmed
    [[ "$status" -eq 0 ]]
}

@test "is_confirmed returns failure for 'n'" {
    REPLY="n"
    run is_confirmed
    [[ "$status" -ne 0 ]]
}
