{ lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks."github.com" = {
      hostname = "github.com";
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
  };

  # Generate an SSH key on first activation and print the public key so it
  # can be added to GitHub/GitLab. No-op on subsequent activations.
  home.activation.generateSshKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]] || ! /usr/bin/ssh-keygen -l -f "$HOME/.ssh/id_ed25519" &>/dev/null; then
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      # Prefer the system ssh-keygen so it resolves the user via the host NSS.
      _keygen=/usr/bin/ssh-keygen
      [[ ! -x "$_keygen" ]] && _keygen=${pkgs.openssh}/bin/ssh-keygen
      "$_keygen" -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "$HOSTNAME"
      echo ""
      echo "── New SSH key generated ───────────────────────────────────"
      echo "Add this public key to GitHub (Settings → SSH and GPG keys):"
      echo ""
      cat "$HOME/.ssh/id_ed25519.pub"
      echo "────────────────────────────────────────────────────────────"
      echo ""
    fi
  '';
}
