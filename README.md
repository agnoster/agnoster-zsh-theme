# agnoster.zsh-theme

A ZSH theme optimized for people who use:

- Solarized
- Git
- Unicode-compatible fonts and terminals (I use iTerm2 + Menlo)
- Python3 and the builtin `venv` module

For Mac users, I highly recommend iTerm 2 + Solarized Dark

**NOTE:** This needs a [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts) for this theme to render correctly I reccomend [Fira Code](https://github.com/tonsky/FiraCode).

To test if your terminal and font support it, check that all the necessary characters are supported by copying the following command to your terminal: `echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"`. The result should look like this:

![Character Example](https://gist.githubusercontent.com/agnoster/3712874/raw/characters.png)

## What does it show?

- If the previous command failed (✘)
- User @ Hostname (if user is not DEFAULT_USER, which can then be set in your profile)
- Git status
  - Branch () or detached head (➦)
  - Current branch / SHA1 in detached head state
  - Dirty working directory (±, color change)
- Working directory
- Elevated (root) privileges (⚡)
#### Fork only:
- Current python venv prompt
- Commit diff from remote
- A snake emoji if a venv is activated

![Screenshot](https://gist.githubusercontent.com/agnoster/3712874/raw/screenshot.png)
