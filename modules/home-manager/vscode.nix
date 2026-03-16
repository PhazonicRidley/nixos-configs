# VSCode home-manager configuration
# Generic settings and extensions - nixd options can be configured per-host
{ pkgs, ... }:

{
  # LSPs and development tools
  home.packages = with pkgs; [
    nixd
    nixfmt
    clang-tools
  ];

  programs.vscode = {
    enable = true;
    profiles."phazonic" = {
      userSettings = {
        "nix.enableLanguageServer" = true;
        "workbench.iconTheme" = "material-icon-theme";
        "nix.formatterPath" = "nixfmt";
        "nix.serverPath" = "nixd";
        "editor.formatOnSave" = true;
        "github.copilot.enable" = {
          "*" = false;
          "plaintext" = false;
          "markdown" = false;
          "scminput" = false;
        };
      };
      extensions =
        with pkgs.vscode-extensions;
        [
          jnoortheen.nix-ide
          ms-python.python
          llvm-vs-code-extensions.vscode-clangd
          ms-vscode.cmake-tools
          vadimcn.vscode-lldb
          pkief.material-icon-theme
          anthropic.claude-code
          ms-vscode-remote.vscode-remote-extensionpack
          ms-vscode-remote.remote-ssh
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }
          {
            name = "gitlens";
            publisher = "eamodio";
            version = "2026.1.704";
            sha256 = "sha256-fxFHRW9ooewKyBlmfOWlhVfq7mSLq3uEe1npST85+dE=";
          }
          {
            name = "discord-vscode";
            publisher = "icrawl";
            version = "5.9.2";
            sha256 = "sha256-43ZAwaApQBqNzq25Uy/AmkQqprU7QlgJVVimfCaiu9k=";
          }
        ];
    };
  };
}
