class Comment < ActiveRecord::Base
  include Humanizer
  require_human_on :create
  default_scope :conditions => ["comments.in_recycling = ? and comments.content_id is not null", false]
  validates :theshiz, :presence => true
	belongs_to :content, :counter_cache => true
	after_save :update_counter_cache
  after_destroy :update_counter_cache
	
  def update_counter_cache
    self.content.active_comments_count = Comment.count( :conditions => ["in_recycling = 0 AND content_id = ?", self.content.id])
    self.content.save
  end
  
  def comment_text
    find_reply = Regexp.new('(^|[\n ])((#)[0-9]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
    generic_URL_regexp = Regexp.new( '(^|[\n ])([\w]+?://[\w]+[^ \"\n\r\t<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
    starts_with_www_regexp = Regexp.new( '(^|[\n ])((www)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
 
    s = self.theshiz
    s.gsub!(find_reply, '\1<a href="\2" class="comment">\2</a>' )
    s.gsub!( generic_URL_regexp, '\1<a href="\2" class="comment">\2</a>' )
    s.gsub!( starts_with_www_regexp, '\1<a href="http://\2" class="comment">\2</a>' )
    s.gsub!("\n", "<br />")
    s
  end
end
