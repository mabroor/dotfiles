# JavaScript/Node.js development environment.
#
# Packages live in the flake's `javascript` devShell:
#   nix develop github:mabroor/dotfiles#javascript
{ config, ... }:

{
  programs.fish.shellAliases = {
    # npm. `nl` is not aliased — it is POSIX number-lines.
    "ni" = "npm install";
    "nrun" = "npm run";
    "ns" = "npm start";
    "nt" = "npm test";
    "nb" = "npm run build";
    "nd" = "npm run dev";
    "nw" = "npm run watch";
    "nlint" = "npm run lint";
    "nf" = "npm run format";

    # Yarn
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

    # pnpm. `pr` is not aliased — it is POSIX paginate.
    "pi" = "pnpm install";
    "prun" = "pnpm run";
    "pstart" = "pnpm start";
    "pt" = "pnpm test";
    "pb" = "pnpm build";
    "pd" = "pnpm dev";
    "pw" = "pnpm watch";
    "pl" = "pnpm lint";
    "pf" = "pnpm format";
    "pa" = "pnpm add";
    "pad" = "pnpm add --save-dev";
    "prm" = "pnpm remove";

    "ncu" = "npm-check-updates";
  };

  home.sessionVariables = {
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";

    # Author identity is derived from the git config rather than hardcoded, so
    # `npm init` stops stamping "Your Name <your.email@example.com>" into every
    # new package.json. NODE_OPTIONS is deliberately unset: pinning
    # --max-old-space-size caps the heap for every Node process, including
    # builds that would otherwise size themselves up on a large machine.
    NPM_CONFIG_INIT_AUTHOR_NAME = config.programs.git.settings.user.name;
    NPM_CONFIG_INIT_AUTHOR_EMAIL = config.programs.git.settings.user.email;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/share/pnpm"
  ];
}
