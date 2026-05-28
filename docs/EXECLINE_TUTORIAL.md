# execline Tutorial

execline is a tiny, non-interactive scripting language. Every command "chain-loads" into the next — no resident interpreter, just a parser that converts the script into one long command line and execs it.

## Key Concepts

### 1. Chain Loading
All commands execute sequentially, each one replacing the current process:
```bash
echo hello world
```
This runs `echo`, then `hello`, then `world` as separate commands. That's why `echo hello world` works — `echo` runs, then `hello` runs (fails), then `world` runs.

Use blocks `{ }` to group commands that should run together:
```bash
foreground { echo hello } echo world
# output: hello, then world
```

### 2. Shebang
```bash
#!/bin/execlineb -S0
```
- `-S<n>` or `-s<n>`: tells execlineb how to handle positional arguments
- `-S0`: no positional args required, `$@` available
- `-S1`: requires at least 1 arg, `$@` = all args
- `-s1`: requires at least 1 arg, `$@` = args after first

### 3. Variables
No internal state — uses the process environment:
```bash
export MYVAR "hello"
echo $MYVAR
```

Fetch env vars with `importas`:
```bash
importas -u VAR ENV_VAR
echo $VAR
```

### 4. Control Flow

**if** — condition on one line, child on next:
```bash
if { test "x" = "x" }
  echo "they match"
```

NOT this (braces on same line as condition):
```bash
if { test "x" = "x" } { echo "bad" }  # WRONG
```

**exec** — replaces current process:
```bash
exec /usr/bin/myapp $@
```

**foreground** — run and wait:
```bash
foreground { command1 } command2
```

**background** — run in background:
```bash
background { long-running-cmd } next-command
```

**pipeline** — pipe output:
```bash
pipeline { echo test } cat
```

### 5. Positional Arguments ($@)

In shell: `$@` expands to all positional parameters.

In execline: `$@` works if you use `-S` or `-s` shebang flag. If not using shebang, you may need `elgetpositionals`.

Test it:
```bash
cat > /tmp/test <<'EOF'
#!/bin/execlineb -S0
echo $@
EOF
chmod +x /tmp/test && /tmp/test arg1 arg2 arg3
# output: arg1 arg2 arg3
```

### 6. Environment Variable Substitution

`${VAR}` in an execline script gets replaced with the value of `VAR` from the environment. If `VAR` is not set, it becomes empty string (not an error).

No `:-` default syntax like shell. Instead use:
```bash
export FALLBACK "/default/path"
if { test -z "$VAR" }
  export VAR $FALLBACK
```

### 7. Common Mistakes

1. **Braces on same line as condition** — child MUST be on next line:
```bash
# WRONG
if { test "x" = "x" } { echo "bad" }

# RIGHT
if { test "x" = "x" }
  echo "good"
```

2. **$@ in -c mode** — use `${@}` explicitly:
```bash
execlineb -c 'echo ${@}' arg1 arg2
```

3. **Missing shebang flags** — without `-S` or `-s`, positional args may not work.

## Example: Entrypoint Script

```bash
#!/bin/execlineb -S0
if { test "$(id -u)" = "0" }
  exec su-exec nobody $BINARY ${@}
exec $BINARY ${@}
```

What this does:
- If running as root (uid=0), exec into `su-exec nobody $BINARY ${@}` to drop to nobody user
- Otherwise, exec directly into `$BINARY ${@}`
- `${@}` passes all container arguments to the binary

## Example: Loop Over Files

```bash
#!/bin/execlineb -P
forbacktickx file { find . -name "*.txt" }
importas -u f file
echo "Processing: ${f}"
```

## Example: Import and Use Env Var

```bash
#!/bin/execlineb -S0
importas -u HOME home
echo "Home is: $HOME"
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `if { cond } child` | Run child if cond exits 0 |
| `exec prog args` | Replace process with prog |
| `foreground { cmds }` | Run cmds, wait for completion |
| `background { cmds }` | Run cmds in background |
| `pipeline { src } sink` | Pipe src output to sink |
| `export VAR value` | Set env var for children |
| `importas -u VAR env` | Copy env to script var |
| `define VAR value` | Literal substitution |

## More Resources

- https://skarnet.org/software/execline/
- https://danyspin97.org/blog/getting-started-with-execline-scripting/