To create `justfile` commands that behave differently based on the operating system (e.g., macOS or Linux), you can use the `os` variable provided by `just`. This variable allows you to detect the current operating system and run commands conditionally.

Here's an example `justfile` to demonstrate how to write OS-specific commands:

```justfile
# Define a variable for the operating system
os := if os() == "macos" { "mac" } else if os() == "linux" { "linux" } else { "unknown" }

# Example task that runs different commands based on the OS
run:
    if os == "mac" {
        echo "Running on macOS"
        # Insert macOS-specific commands here
    } else if os == "linux" {
        echo "Running on Linux"
        # Insert Linux-specific commands here
    } else {
        echo "Unsupported OS"
        exit 1
    }

# Another task for macOS only
mac-task:
    if os != "mac" {
        echo "This task is only for macOS"
        exit 1
    }
    echo "Running macOS-specific task"
    # Insert macOS commands

# Another task for Linux only
linux-task:
    if os != "linux" {
        echo "This task is only for Linux"
        exit 1
    }
    echo "Running Linux-specific task"
    # Insert Linux commands
```

### Explanation:
1. **Detecting the OS**: The `os()` function returns the current operating system as a string (`"macos"`, `"linux"`, `"windows"`, etc.).
2. **Conditional Logic**: Use `if` and `else` to execute different commands based on the OS.
3. **Specific Tasks**: You can create tasks specifically for macOS or Linux by checking the `os` variable.

### Running Commands:
To execute a task, run the following in your terminal:
```bash
just run
just mac-task
just linux-task
```

This approach ensures your `justfile` can adapt to different environments seamlessly.
_________
To modify the script so it checks if a specific Rust `cargo` target is added (e.g., for cross-compilation) and adds it if not, you can use the `cargo` command to list and add targets as needed. Here's the updated script:

```sh
#!/bin/bash

# Define the target to check/add
TARGET="x86_64-unknown-linux-gnu"

# Function to check and add cargo target
check_and_add_cargo_target() {
    if cargo target list | grep -q "^$TARGET$"; then
        echo "Cargo target '$TARGET' is already added."
    else
        echo "Cargo target '$TARGET' is not added. Adding it now..."
        cargo target add "$TARGET"
        if [[ $? -eq 0 ]]; then
            echo "Cargo target '$TARGET' added successfully."
        else
            echo "Failed to add cargo target '$TARGET'."
            exit 1
        fi
    fi
}

if [[ "$(uname)" == "Darwin" ]]; then
    echo "Running on macOS"
    check_and_add_cargo_target
    # Insert macOS-specific commands here
elif [[ "$(uname)" == "Linux" ]]; then
    echo "Running on Linux"
    check_and_add_cargo_target
    # Insert Linux-specific commands here
else
    echo "Unsupported OS"
    exit 1
fi
```

### Explanation:
1. **Define the Target**: Set the `TARGET` variable to the desired Rust target (e.g., `x86_64-unknown-linux-gnu`).
2. **Check Existing Targets**: Use `cargo target list` to list all available targets and check if the desired target is already added with `grep`.
3. **Add the Target**: If not already present, add the target using `cargo target add "$TARGET"`.
4. **OS-Specific Commands**: Wrap the logic in a function and call it in the appropriate OS blocks (`Darwin` for macOS, `Linux` for Linux).

### Save and Run:
1. Save the script, e.g., `cargo-target-check.sh`.
2. Make it executable:
   ```sh
   chmod +x cargo-target-check.sh
   ```
3. Run the script:
   ```sh
   ./cargo-target-check.sh
   ``` 

This ensures the target is checked and added if needed, regardless of the OS.
