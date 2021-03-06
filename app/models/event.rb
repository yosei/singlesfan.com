class Event < ActiveRecord::Base
  belongs_to :master
  belongs_to :picture

  validates_presence_of :title
  validates_presence_of :opendate
  validates_presence_of :opentime
  validates_uniqueness_of :opentime, scope: [:opendate]
  validates_presence_of :master_id

  scope :recents, lambda { where("opendate >= ?",Date.today.to_s).order("opendate, opentime") }
  scope :recents_by_created, lambda { order("created_at DESC") }
  scope :monthly, lambda { |d|
    b = d.beginning_of_month
    e = d.end_of_month
    where("opendate between ? AND ?",b,e).order("opendate, opentime")
  }
  scope :pasts, lambda { |p|
    if p == nil
      PAGE_SIZE = 8
      where("opendate <= ?",Date.today.to_s).order("opendate DESC,opentime").limit(PAGE_SIZE)
    else
      PAGE_SIZE = 24
      o = p * PAGE_SIZE
      where("opendate < ?",Date.today.to_s).order("opendate DESC,opentime").offset(o).limit(PAGE_SIZE)
    end
  }

  # for new form
  attr_accessor :master_name

  def opendate_short
    d = opendate.day.to_s
    w = %w(日 月 火 水 木 金 土)[opendate.wday]
    d+w
  end

  def opentime_short(html=true)
    l = %w(昼 夜 昼夜)[opentime]
    return l unless html
    if opentime == 0 then
      i = ActionController::Base.helpers.image_tag("sun.png",size: "16x16", title: l)
    elsif opentime == 1 then
      i = ActionController::Base.helpers.image_tag("moon.png",size: "16x16", title: l)
    elsif opentime == 2 then
      i = ActionController::Base.helpers.image_tag("sun.png",size: "16x16", title: l)
      i += ActionController::Base.helpers.image_tag("moon.png",size: "16x16", title: l)
    end
    h = i

    return h.html_safe
  end

  def opentime_long
    opentime_short + " (" +%w(13:00-18:00 19:30-23:00 13:00-23:00)[opentime] + ")"
  end

  def title_(link=false)
    if link
      n = "<a href='events/"+id.to_s+"'>"+title+"</a>"
      return n.html_safe
    else
      return title
    end
  end

  def masters_name(link=false)
    return "" if master == nil || master.id == 1
    if link
      n = ("<a href='masters/"+master.id.to_s+"'>").html_safe
      n += master.name
      n += "</a>".html_safe
    else
      n = master.name
    end
    if submaster_id then
      n += "&"
      if link
        n += ("<a href='masters/"+submaster_id.to_s+"'>").html_safe
        n += Master.find(submaster_id).name
        n += "</a>".html_safe
      else
        n += Master.find(submaster_id).name
      end
    end
    return n
  end
end
