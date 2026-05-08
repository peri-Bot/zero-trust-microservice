{
  description = "Zero-Trust Microservices with K3s, Istio, and Vault";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs;[
            # Programming Languages
            go
            nodejs_20

            # Kubernetes & Infrastructure
            kubectl # K8s CLI
            kubernetes-helm # Helm package manager
            k9s # Terminal UI for K8s debugging

            # Service Mesh & Security
            istioctl # Istio CLI
            vault # HashiCorp Vault CLI
          ];

          shellHook = ''
            echo "🛡️  Zero-Trust Microservices Env Loaded! 🛡️"
            echo "Make sure K3s is running via systemd on your Arch host."
            echo "Tools available: go, node, kubectl, helm, istioctl, vault, k9s"
          '';
        };
      }
    );
}
