class Devexec < Formula
  desc "Devexec make it easy to switch PATH for executing command"
  homepage "http://github.com/kateinoigakukun/devexec"
  head "http://github.com/kateinoigakukun/devexec.git"

  depends_on :xcode => ["11.5", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
    zsh_completion.install "libexec/_devexec"
  end

  test do
    system bin/"devexec" "list"
  end
end
