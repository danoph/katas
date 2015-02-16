class LookAndSay

  def initialize(items)
    if items.kind_of? Array
      @sequence = items.collect(&:to_s).join('')
    else
      @sequence = items
    end
    @says = []
    @next_items = ''
    array = @sequence.split('')
    i = 0
    while i < array.length do
      current = array[i]
      unless (current.to_i.to_s == current) then
        raise ArgumentError.new("Should not allow strings with non-digit characters")
      end
      count = 1
      i += 1
      while current == array[i] do
        count += 1
        i += 1
      end
      @next_items += "#{count}#{current}"
    end
  end

  def next
    LookAndSay.new(@next_items)
  end

  def to_s
    @sequence
  end

end
