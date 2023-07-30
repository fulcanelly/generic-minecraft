module AnimationsService
  def self.loading_proc
    state_index = 0

     proc do |size|
      state_index += 1
      load_elements = ["\\", "|", "/", "-"]

      progress = '.' * (size / (1024 * 1024))

      animation = load_elements[state_index % load_elements.size]

      print "\rLoading: #{progress}#{animation}"
    end
  end
end