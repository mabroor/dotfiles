# JavaScript/Node.js development environment
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js runtime and package managers
    nodejs_20        # Node.js LTS
    npm              # Node package manager
    yarn             # Alternative package manager
    pnpm             # Fast, disk space efficient package manager
    bun              # Fast all-in-one JavaScript runtime
    
    # Development tools
    nodePackages.typescript              # TypeScript compiler
    nodePackages.typescript-language-server  # TypeScript LSP
    nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON LSP
    nodePackages.prettier               # Code formatter
    nodePackages.eslint                 # JavaScript linter
    nodePackages.stylelint              # CSS linter
    
    # Build tools and bundlers
    nodePackages.webpack-cli            # Webpack bundler
    nodePackages.vite                   # Fast build tool
    nodePackages.parcel                 # Zero-config bundler
    
    # Testing frameworks
    nodePackages.jest                   # JavaScript testing framework
    nodePackages.vitest                 # Vite-native test runner
    
    # Utilities
    nodePackages.nodemon                # Development file watcher
    nodePackages.concurrently          # Run multiple commands
    nodePackages.cross-env              # Cross-platform environment variables
    nodePackages.npm-check-updates      # Check for outdated dependencies
    
    # React development
    nodePackages.create-react-app       # React project bootstrapper
    
    # Vue development
    nodePackages."@vue/cli"             # Vue CLI
    
    # Angular development  
    nodePackages."@angular/cli"         # Angular CLI
    
    # Svelte development
    nodePackages.svelte-language-server # Svelte LSP
    
    # Database tools
    nodePackages.prisma                 # Modern database toolkit
    
    # Deployment tools
    nodePackages.vercel                 # Vercel CLI
    nodePackages.netlify-cli            # Netlify CLI
    
    # Documentation
    nodePackages.jsdoc                 # JavaScript documentation generator
    
    # Package analysis
    nodePackages.npm-check             # Check npm dependencies
    nodePackages.depcheck              # Check unused dependencies
  ];

  # Shell aliases for JavaScript development
  programs.fish.shellAliases = {
    # Node.js aliases
    "ni" = "npm install";
    "nr" = "npm run";
    "ns" = "npm start";
    "nt" = "npm test";
    "nb" = "npm run build";
    "nd" = "npm run dev";
    "nw" = "npm run watch";
    "nl" = "npm run lint";
    "nf" = "npm run format";
    
    # Yarn aliases
    "yi" = "yarn install";
    "yr" = "yarn run";
    "ys" = "yarn start";
    "yt" = "yarn test";
    "yb" = "yarn build";
    "yd" = "yarn dev";
    "yw" = "yarn watch";
    "yl" = "yarn lint";
    "yf" = "yarn format";
    "ya" = "yarn add";
    "yad" = "yarn add --dev";
    "yrm" = "yarn remove";
    
    # pnpm aliases
    "pi" = "pnpm install";
    "pr" = "pnpm run";
    "ps" = "pnpm start";
    "pt" = "pnpm test";
    "pb" = "pnpm build";
    "pd" = "pnpm dev";
    "pw" = "pnpm watch";
    "pl" = "pnpm lint";
    "pf" = "pnpm format";
    "pa" = "pnpm add";
    "pad" = "pnpm add --save-dev";
    "prm" = "pnpm remove";
    
    # Utility aliases
    "ncu" = "npm-check-updates";
    "deps-check" = "depcheck";
    "deps-unused" = "depcheck --unused-devDependencies";
  };

  # Environment variables
  home.sessionVariables = {
    # Use pnpm as default package manager for some tools
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
    
    # Node.js options
    NODE_OPTIONS = "--max-old-space-size=4096";
    
    # npm configuration
    NPM_CONFIG_INIT_AUTHOR_NAME = "Your Name";
    NPM_CONFIG_INIT_AUTHOR_EMAIL = "your.email@example.com";
    NPM_CONFIG_INIT_LICENSE = "MIT";
  };

  # Add pnpm to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/pnpm"
  ];

  # Create useful development scripts
  home.file.".local/bin/js-project-init" = {
    text = ''
      #!/usr/bin/env bash
      # JavaScript project initialization script
      
      set -euo pipefail
      
      PROJECT_NAME="$1"
      PROJECT_TYPE="$2" # react, vue, angular, node, or vanilla
      
      if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_TYPE" ]; then
          echo "Usage: $0 <project-name> <project-type>"
          echo "Project types: react, vue, angular, node, vanilla"
          exit 1
      fi
      
      echo "🚀 Creating $PROJECT_TYPE project: $PROJECT_NAME"
      
      case "$PROJECT_TYPE" in
          "react")
              npx create-react-app "$PROJECT_NAME" --template typescript
              ;;
          "vue")
              npx @vue/cli create "$PROJECT_NAME" --default
              ;;
          "angular")
              npx @angular/cli new "$PROJECT_NAME" --routing --style=scss
              ;;
          "node")
              mkdir "$PROJECT_NAME"
              cd "$PROJECT_NAME"
              npm init -y
              npm install --save-dev @types/node typescript nodemon
              echo "console.log('Hello, Node.js!');" > index.js
              ;;
          "vanilla")
              mkdir "$PROJECT_NAME"
              cd "$PROJECT_NAME"
              npm init -y
              mkdir src
              echo "console.log('Hello, JavaScript!');" > src/index.js
              echo "<!DOCTYPE html><html><head><title>$PROJECT_NAME</title></head><body><script src=\"src/index.js\"></script></body></html>" > index.html
              ;;
          *)
              echo "❌ Unknown project type: $PROJECT_TYPE"
              exit 1
              ;;
      esac
      
      echo "✅ Project $PROJECT_NAME created successfully!"
      echo "📁 Navigate to the project: cd $PROJECT_NAME"
    '';
    executable = true;
  };

  # Package.json generator script
  home.file.".local/bin/package-json-gen" = {
    text = ''
      #!/usr/bin/env bash
      # Generate a comprehensive package.json with common scripts
      
      set -euo pipefail
      
      PROJECT_NAME="$(basename "$PWD")"
      
      cat > package.json << EOF
      {
        "name": "$PROJECT_NAME",
        "version": "1.0.0",
        "description": "",
        "main": "index.js",
        "scripts": {
          "start": "node index.js",
          "dev": "nodemon index.js",
          "build": "echo 'Build script not configured'",
          "test": "jest",
          "test:watch": "jest --watch",
          "test:coverage": "jest --coverage",
          "lint": "eslint .",
          "lint:fix": "eslint . --fix",
          "format": "prettier --write .",
          "format:check": "prettier --check .",
          "type-check": "tsc --noEmit",
          "clean": "rm -rf dist build node_modules/.cache",
          "deps:update": "npm-check-updates -u",
          "deps:check": "npm audit"
        },
        "keywords": [],
        "author": "",
        "license": "MIT"
      }
      EOF
      
      echo "✅ Generated package.json with common scripts"
      echo "📝 Don't forget to update the description, author, and keywords"
    '';
    executable = true;
  };
}