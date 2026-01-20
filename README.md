# gcmd

A natural language shell command executor. Describe what you want in plain English, and gcmd converts it to a shell command using OpenAI.

## Installation

```bash
sudo ./install.sh
```

Set your OpenAI API key:

```bash
export OPENAI_API_KEY='your-api-key'
```

Add to `~/.zshrc` or `~/.bashrc` to make it permanent.

## Usage

```bash
gcmd <natural language description>
```

### Examples

```bash
gcmd list all files sorted by size
gcmd find python files modified in the last week
gcmd show disk usage of current directory
gcmd compress the src folder into a tar.gz
```

The generated command is displayed for review. Press `Y` or Enter to execute, `N` to abort.

## Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | OpenAI API key | Required |
| `GCMD_MODEL` | Model to use | `gpt-4o-mini` |

## Uninstall

```bash
sudo ./install.sh --uninstall
```
