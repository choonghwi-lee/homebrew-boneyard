class DynamodbLocal < Formula
  # see http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html
  desc "Client-side database and server imitating DynamoDB"
  homepage "https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Tools.DynamoDBLocal.html"
  url "https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz"
  version "2016-05-17"
  sha256 "e19da7bd19454052aaf7cdb02516e011612f0f6379f9dd3ad7af4e36068209b3"

  bottle :unneeded

  def data_path
    var/"data/dynamodb-local"
  end

  def log_path
    var/"log/dynamodb-local.log"
  end

  def bin_wrapper
    <<~EOS
      #!/bin/sh
      cd #{data_path} && PATH="/opt/homebrew/opt/openjdk/bin:$PATH" exec java -Djava.library.path=#{libexec}/DynamodbLocal_lib -jar #{libexec}/DynamoDBLocal.jar "$@"
    EOS
  end

  def install
    libexec.install %w[DynamoDBLocal_lib DynamoDBLocal.jar]
    (bin/"dynamodb-local").write(bin_wrapper)
  end

  def post_install
    data_path.mkpath
  end

  def caveats
    <<~EOS
      DynamoDB Local supports the Java Runtime Engine (JRE) version 6.x or
      newer; it will not run on older JRE versions.

      In this release, the local database file format has changed;
      therefore, DynamoDB Local will not be able to read data files
      created by older releases.

      Data: #{data_path}
      Logs: #{log_path}
    EOS
  end

  plist_options manual: "#{HOMEBREW_PREFIX}/bin/dynamodb-local"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/dynamodb-local</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{log_path}</string>
      </dict>
      </plist>
    EOS
  end

  test do
    system bin/"dynamodb-local", "-help"
  end
end
