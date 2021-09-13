# Protopaint V2

Paint application in the browser using a CLUI interface. Export is by default a SVG. Still a major work in progress.

### Local Development Setup

Instructions are for macOS. Linux is very similar and windows can be done through WSL. This project is just a static frontend so using these exact instructions are not technically needed but I wanted local SSL and hostnames for development.

1. Add to `/etc/hosts`:
```txt
# Protopaint Start
127.0.0.1 dev.protopaint.local prod.protopaint.local test.protopaint.local protopaint.local
# Protopaint End
```

2. Add to `~/.zshrc` making sure path is correct:
```txt
# Protopaint Start
function paint {
        cd /absolute/path/to/protopaint-v2 && bash protopaint.sh $*
        cs -
}
# Protopaint End
```

3. Run `source ~/.zshrc`.
   
4. Run `paint init`.
   
5. Navigate to `https://prod.protopaint.local/` to view the project after it is has most recently passed all test locally or `https://dev.protopaint.local/` to view the project with its most recent successful local build.

### Development

- Run `npm run dev` to continuously rebuild the project when working on changes to view at `https://dev.protopaint.local/`.
  
- Run `npm run dist` to rebuild the project, run all test, and then push changes to show up on `https://prod.protopaint.local/`

- View test at `https://test.protopaint.local`