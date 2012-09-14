# agnoster.zsh-theme

A ZSH theme optimized for people who use:

- Solarized
- Git
- Unicode-compatible fonts and terminals (I use iTerm2 + Menlo)

To test if your terminal and font support it, check that all the necessary characters are supported by copying the following command to your terminal: `echo "⮀±⭠ ➦✔✘⚡"`. The result should look like this:

![Character Example](http://cl.ly/image/3m3b0k2g2Y1A/Screen%20Shot%202012-09-14%20at%2012.01.14%20.png)

## What does it show?

- Success (✔) or failure (✘) of previous command
- Hostname
- Git status
  - Branch (⭠) or detached head (➦)
  - Current branch / SHA1 in detached head state
  - Dirty working directory (±, color change)
- Working directory
- Elevated (root) privileges (⚡)

![Screenshot](https://gist.github.com/raw/3712874/de4828056ec1f04b03dbf4940f1b61e525ec9799/screenshot.png)

## Future Work

I don't want to clutter it up too much, but I am toying with the idea of adding RVM (ruby version) and n (node.js version) display.

It's currently hideously slow, especially inside a git repo. I guess it's not overly so for comparable themes, but it bugs me, and I'd love to hear ideas about how to improve the performance.

Would be nice for the code to be a bit more sane and re-usable. Something to easily append a section with a given FG/BG, and add the correct opening and closing.