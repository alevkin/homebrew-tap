class Aikeeper < Formula
  desc "Local-only AI token usage daemon and dashboard"
  homepage "https://github.com/alevkin/ai-keeper"
  url "https://github.com/alevkin/ai-keeper/releases/download/v0.30.2/aikeeper-v0.30.2.tar.gz"
  sha256 "f3f9546d6d6f69a98e8236282f8ad47d50c7956c72624b2431c1364b2150af00"

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

  def post_install
    return if ENV["AIKEEPER_SKIP_AUTO_INSTALL"] == "1"

    system bin/"aikeeper-install", "--port", ENV.fetch("AIKEEPER_PORT", "8766")
  end

  test do
    system bin/"aikeeper-install", "--help"
  end

  def caveats
    <<~EOS
      AI Keeper is local-only and metadata-only.
      Local setup runs automatically after install.
      Dashboard: http://127.0.0.1:8766
      Repair setup: aikeeper-install --port 8766
      Custom port: AIKEEPER_PORT=8770 brew install alevkin/tap/aikeeper
      Skip setup: AIKEEPER_SKIP_AUTO_INSTALL=1 brew install alevkin/tap/aikeeper
    EOS
  end
end
