# encoding: utf-8

require 'diff_splitter'

describe RailsDiff::DiffSplitter do
  let(:diff_splitter) { described_class.new diff }
  let(:diff) { <<-END
diff -ur tmp/generated/v3.1.1/railsdiff/Gemfile tmp/generated/v3.2.6/railsdiff/Gemfile
index 0a5b233..0ace91f 100644
--- a/Gemfile
+++ b/Gemfile
@@ -1,9 +1,9 @@
-source 'http://rubygems.org'
+source 'https://rubygems.org'
-gem 'rails', '3.1.2'
+gem 'rails', '3.2.6'
@@ -11,8 +11,12 @@ gem 'sqlite3'
-  gem 'sass-rails',   '~> 3.1.5.rc.2'
-  gem 'coffee-rails', '~> 3.1.1'
+  gem 'sass-rails',   '~> 3.2.3'
+  gem 'coffee-rails', '~> 3.2.1'
diff -ur tmp/generated/v3.1.1/railsdiff/config/routes.rb tmp/generated/v3.2.6/railsdiff/config/routes.rb
index 2c8e7db..f01137d 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -54,5 +54,5 @@ App::Application.routes.draw do
-  # match ':controller(/:action(/:id(.:format)))'
+  # match ':controller(/:action(/:id))(.:format)'
END
  }

  describe '#split' do
    subject { diff_splitter.split }

    specify { should be_kind_of(Hash) }
    specify { subject.keys.should =~ %w[Gemfile config/routes.rb] }

    it 'starts each diff with @' do
      subject.values.each { |diff| diff =~ /^@/ }
    end
  end
end
