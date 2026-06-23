{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { nixpkgs, ... }:
    let
      each =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-darwin"
          "x86_64-linux"
          "aarch64-darwin"
          "aarch64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});
    in
    {
      devShells = each (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            cargo # https://github.com/rust-lang/cargo
            clippy # https://github.com/rust-lang/rust-clippy
            jq # https://github.com/jqlang/jq
            rust-analyzer # https://github.com/rust-lang/rust-analyzer
            rustc # https://github.com/rust-lang/rust
            rustfmt # https://github.com/rust-lang/rustfmt
            tmux # https://github.com/tmux/tmux
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      });
      packages = each (pkgs: {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = "recon";
          version = "0.6.1";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
          doCheck = true;
          nativeBuildInputs = [
            pkgs.makeWrapper
          ];
          postInstall = ''
            wrapProgram $out/bin/recon \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.tmux ]}
          '';
          meta = {
            description = "tmux-native dashboard for managing Claude Code agents";
            homepage = "https://github.com/gavraz/recon";
            license = pkgs.lib.licenses.mit;
            mainProgram = "recon";
          };
        };
      });
    };
}
