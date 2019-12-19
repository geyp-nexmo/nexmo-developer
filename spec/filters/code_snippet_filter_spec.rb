require 'rails_helper'

RSpec.describe CodeSnippetFilter do
  it 'returns input unaltered if it does not match' do
    input = 'hello'

    expect(described_class.call(input)).to eq('hello')
  end

  it 'returns an error if no input provided' do
    expect { described_class.call }.to raise_error(ArgumentError)
  end

  it 'returns code snippet in the code only template if code only parameter is defined as true' do
    allow(File).to receive(:exist?).and_call_original
    expect(File).to receive(:exist?).with(/example_snippet/).and_return(true)
    expect(File).to receive(:read).with(/example_snippet/).and_return(example_source_file)
    expect(File).to receive(:read).with(/code_only/).and_return(code_only_template)

    input = <<~HEREDOC
      ```single_code_snippet
      language: ruby
      title: Ruby
      code:
        source: .repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb
        from_line: 18
        to_line: 32
      unindent: false
      code_only: true
      ```
    HEREDOC

    expect(described_class.call(input)).to match_snapshot('code_snippet_filter/code_only_default')
  end

  it 'returns full code snippet with run instructions and prerequisites if code only parameter is undefined or false' do
    allow(File).to receive(:exist?).and_call_original
    expect(File).to receive(:exist?).with(/example_snippet/).and_return(true)
    expect(File).to receive(:read).with(/example_snippet/).and_return(example_source_file)
    expect(File).to receive(:read).with(/write_code/).and_return(write_code_template)

    input = <<~HEREDOC
      ```single_code_snippet
      language: ruby
      title: Ruby
      code:
        source: .repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb
        from_line: 18
        to_line: 32
      unindent: false
      ```
    HEREDOC

    expect(described_class.call(input)).to match_snapshot('code_snippet_filter/code_snippet_default')
  end

  it 'generates application_html with defaults if no default provided' do
    # base_url = 'http://demo.ngrok.io'
    # app['name'] = 'ExampleProject'
    # app['type'] = 'voice'
    # app['event_url'] = "#{base_url}/webhooks/events"
    # app['answer_url'] = "#{base_url}/webhooks/answer"
    # erb = File.read("#{Rails.root}/app/views/code_snippets/_application_voice.html.erb") <-- stub this file call
    # id = stub SecureRandom.hex
    # what's returned is ERB.new(erb).result(binding)
  end

  it 'generates application_html with values if values provided' do
    # stub values and send it to private method
  end

  it 'raises an exception if language is not known' do
    input = <<~HEREDOC
      ```single_code_snippet
      language: klingon
      title: Ruby
      code:
        source: .repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb
        from_line: 18
        to_line: 32
      unindent: false
      ```
    HEREDOC

    expect { described_class.call(input) }.to raise_error('Unknown language: klingon')
  end

  it 'raises an exception if language file does not exist' do
    allow(File).to receive(:exist?).and_call_original
    expect(File).to receive(:exist?).with(/example_snippet/).and_return(false)

    input = <<~HEREDOC
      ```single_code_snippet
      language: ruby
      title: Ruby
      code:
        source: .repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb
        from_line: 18
        to_line: 32
      unindent: false
      ```
    HEREDOC

    expect { described_class.call(input) }.to raise_error("CodeSnippetFilter - Could not load #{Rails.root}/.repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb for language ruby")
  end

  it 'raises an exception if application is specified but type is not recognized' do
    input = <<~HEREDOC
      ```single_code_snippet
      language: ruby
      title: Ruby
      code:
        source: .repos/nexmo/nexmo-ruby-code-snippets/example/example_snippet.rb
        from_line: 18
        to_line: 32
      application:
        type: 'klingon_warbird'
      unindent: false
      ```
    HEREDOC

    expect { described_class.call(input) }.to raise_error("Invalid application type when creating code snippet: 'klingon_warbird'")
  end

  it 'dependency_html is an empty string if there are no dependencies' do
  end

  it 'client_html is an empty string if there is no highlighted_client_source' do
  end

  it 'client_html holds client config instructions in ERB format if there is highlighted_client_source' do
  end

  it 'reads code only snippet data if code only is specified' do
  end

  it 'reads write code snippet data if code only is not specified' do
  end
end

def example_source_file
  <<~HEREDOC
    require 'dotenv/load'
    require 'nexmo'

    NEXMO_API_KEY = ENV['NEXMO_API_KEY']
    NEXMO_API_SECRET = ENV['NEXMO_API_SECRET']
    NEXMO_APPLICATION_ID = ENV['NEXMO_APPLICATION_ID']
    NEXMO_APPLICATION_PRIVATE_KEY_PATH = ENV['NEXMO_APPLICATION_PRIVATE_KEY_PATH']
    NEXMO_NUMBER = ENV['NEXMO_NUMBER']
    TO_NUMBER = ENV['TO_NUMBER']

    client = Nexmo::Client.new(
      api_key: NEXMO_API_KEY,
      api_secret: NEXMO_API_SECRET,
      application_id: NEXMO_APPLICATION_ID,
      private_key: File.read(NEXMO_APPLICATION_PRIVATE_KEY_PATH)
    )

    response = client.calls.create(
      to: [{
        type: 'phone',
        number: TO_NUMBER
      }],
      from: {
        type: 'phone',
        number: NEXMO_NUMBER
      },
      answer_url: [
        'https://developer.nexmo.com/ncco/tts.json'
      ]
    )

    puts response.inspect
  HEREDOC
end

def code_only_template
  <<~HEREDOC
    <div class="copy-wrapper">
      <div class="copy-button" data-lang="<%= lang %>" data-block="<%= config['source'] %>" data-section="code">
        <%= octicon "clippy", :class => 'top left' %> <span><%= I18n.t('.copy-to-clipboad') %></span>
      </div>
      <pre class="highlight <%= lexer.tag %> main-code"><code><%= highlighted_code_source %></code></pre>
    </div>
  HEREDOC
end

def write_code_template
  <<~HEREDOC
    <h2 class="Vlt-title--margin-top3"><%= I18n.t('.code_snippets.write_code.write_the_code') %></h2>
    <%= add_instructions %>

    <div class="copy-wrapper">
      <div class="copy-button" data-lang="<%= lang %>" data-block="<%= config['source'] %>" data-section="code">
        <%= octicon "clippy", :class => 'top left' %> <span><%= I18n.t('.code_snippets.copy_to_clipboard') %></span>
      </div>
      <pre class="highlight <%= lexer.tag %> main-code"><code><%= highlighted_code_source %></code></pre>

    </div>

    <p><a data-section="code" data-lang="<%= lang %>" data-block="<%= config['source'] %>" href="<%= source_url %>"><%= I18n.t('.code_snippets.write_code.view_full_source') %></a></p>
  HEREDOC
end