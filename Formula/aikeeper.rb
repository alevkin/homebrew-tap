class Aikeeper < Formula
  desc "Local-only AI token usage daemon and dashboard"
  homepage "https://github.com/alevkin/ai-keeper"
  url "https://github.com/alevkin/ai-keeper/releases/download/v0.30.3/aikeeper-v0.30.3.tar.gz"
  sha256 "7c4dd4fe0e332090612678d0ee732c3e6a93125d5c1682f630368e7ce49678a0"

  depends_on "uv"

  def install
    libexec.install Dir["*"]
    inreplace libexec/"pyproject.toml", 'readme = "README.md"', 'readme = "../README.md"'
    (bin/"aikeeper-install").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/install.sh" "$@"
    EOS
    (bin/"aikeeper-install-git-hooks").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/install-git-hooks.sh" "$@"
    EOS
    (bin/"aikeeper-upgrade").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/upgrade.sh" "$@"
    EOS
    (bin/"aikeeper-rollback").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/rollback.sh" "$@"
    EOS
    (bin/"aikeeper-publish").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/publish.sh" "$@"
    EOS
    (bin/"aikeeper-sign").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/sign-release.sh" "$@"
    EOS
    (bin/"aikeeper-release").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/release.sh" "$@"
    EOS
    (bin/"aikeeper-public-release-gate").write <<~EOS
      #!/usr/bin/env bash
      exec "#{libexec}/scripts/public-release-gate.sh" "$@"
    EOS
    chmod 0755, bin/"aikeeper-install"
    chmod 0755, bin/"aikeeper-install-git-hooks"
    chmod 0755, bin/"aikeeper-upgrade"
    chmod 0755, bin/"aikeeper-rollback"
    chmod 0755, bin/"aikeeper-publish"
    chmod 0755, bin/"aikeeper-sign"
    chmod 0755, bin/"aikeeper-release"
    chmod 0755, bin/"aikeeper-public-release-gate"
  end

  test do
    system bin/"aikeeper-install", "--help"
  end

  def caveats
    <<~EOS
      AI Keeper is local-only and metadata-only.
      Run setup after install:
        aikeeper-install --port 8766

      Dashboard: http://127.0.0.1:8766
      Repair setup: aikeeper-install --port 8766
      Custom port: aikeeper-install --port 8770
    EOS
  end
end
