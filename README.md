# Colorless

Colorless is a wrapper to enable colorised command output and pipe it to
[`less(1)`](https://man.netbsd.org/less.1).

Source code: <https://github.com/suominen/colorless>

## Setup

To use `colorless` simply call it to create aliases for the commands it
knows about.

Add the following to `~/.bashrc`:

```
    eval "$(colorless -as)"
```

Add the following to `~/.tcshrc`:

```
    eval `colorless -ac`
```

You can also create `~/.colorless.conf` to add more commands:

```
    command:--color
```

The command does not need to support colorised output. You can still use
`colorless` to page its output.  Example aliases:

Bourne shell:

```
    $ colorless -a
    alias diff='colorless diff';
    alias jq='colorless jq';
    alias ls='colorless ls';
```

C shell:

```
    % colorless -a
    alias diff 'colorless diff';
    alias jq 'colorless jq';
    alias ls 'colorless ls';
```
