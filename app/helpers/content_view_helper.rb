module ContentViewHelper

  #
  # content header section helper
  #
  def content_header_section options={ heading: :h1 }, text
    content_tag :section, class: 'content-header' do 
      content_tag options[:heading].to_sym do
        block_given?? yield : text.try(:html_safe)
      end
    end
  end

  #
  # content section helper
  #
  def content_section &block
    content_tag :section, class: 'content' do 
      yield
    end
  end

  def label content, options={}
    content_tag :span, class: "label #{options[:label_class]}" do 
      content.try(:html_safe)
    end
  end

  def breadcrumbs
    '<ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> Home</a></li>
        <li><a href="#">Examples</a></li>
        <li class="active">User profile</li>
      </ol>
    </section>'
  end

end