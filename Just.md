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
