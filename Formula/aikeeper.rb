class Aikeeper < Formula
  desc "Local-only AI token usage daemon and dashboard"
  homepage "https://github.com/alevkin/ai-keeper"
  url "https://github.com/alevkin/ai-keeper/releases/download/v0.30.8/aikeeper-v0.30.8.tar.gz"
  sha256 "b50a150b23b5c55b7adcf4264f4ae3bd84db304ab603f128b21aa01439bc6d34"

  on_macos do
    on_arm do
      resource "uv" do
        url "https://github.com/astral-sh/uv/releases/download/0.11.21/uv-aarch64-apple-darwin.tar.gz"
        sha256 "1f921d491ba5ffeea774eb04d6681ecee379101341cbb1500394993b541bf3f4"
      end
    end

    on_intel do
      resource "uv" do
        url "https://github.com/astral-sh/uv/releases/download/0.11.21/uv-x86_64-apple-darwin.tar.gz"
        sha256 "f3c8e5708a84b920c18b691214d54d2b0da6b984789caae95d47c95120cb7765"
      end
    end
  end

  on_linux do
    on_arm do
      resource "uv" do
        url "https://github.com/astral-sh/uv/releases/download/0.11.21/uv-aarch64-unknown-linux-gnu.tar.gz"
        sha256 "88e800834007cc5efd4675f166eb2a51e7e3ad19876d85fa8805a6fb5c922397"
      end
    end

    on_intel do
      resource "uv" do
        url "https://github.com/astral-sh/uv/releases/download/0.11.21/uv-x86_64-unknown-linux-gnu.tar.gz"
        sha256 "8c88519b0ef0af9801fcdee419bbb12116bd9e6b18e162ae093c932d8b264050"
      end
    end
  end

  def install
    libexec.install Dir["*"]
    inreplace libexec/"pyproject.toml", 'readme = "README.md"', 'readme = "../README.md"'
    resource("uv").stage do
      uv_files = Dir["uv", "uvx", "uv-*/*"]
      raise "uv resource did not contain uv or uvx" if uv_files.empty?

      (libexec/"vendor"/"uv").install uv_files
    end
    (bin/"aikeeper").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      if [[ ! -x "#{libexec}/.venv/bin/aikeeper" ]]; then
        "#{libexec}/vendor/uv/uv" --directory "#{libexec}" sync --frozen --no-dev >/dev/null
      fi
      exec "#{libexec}/.venv/bin/aikeeper" "$@"
    EOS
    (bin/"aikeeper-install").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/install.sh" "$@"
    EOS
    (bin/"aikeeper-install-git-hooks").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/install-git-hooks.sh" "$@"
    EOS
    (bin/"aikeeper-upgrade").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/upgrade.sh" "$@"
    EOS
    (bin/"aikeeper-rollback").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/rollback.sh" "$@"
    EOS
    (bin/"aikeeper-publish").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/publish.sh" "$@"
    EOS
    (bin/"aikeeper-sign").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/sign-release.sh" "$@"
    EOS
    (bin/"aikeeper-release").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/release.sh" "$@"
    EOS
    (bin/"aikeeper-public-release-gate").write <<~EOS
      #!/usr/bin/env bash
      export PATH="#{libexec}/vendor/uv:$PATH"
      exec "#{libexec}/scripts/public-release-gate.sh" "$@"
    EOS
    chmod 0755, bin/"aikeeper"
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
      Doctor: aikeeper doctor --port 8766
      Repair setup: aikeeper-install --port 8766
      Custom port: aikeeper-install --port 8770
    EOS
  end
end
