module NodeUtilities
  def set_namespace(new_namespace)
    @namespace = new_namespace
  end

  def set_default(key, value)
    key = key.to_sym
    node_hash = node
    if @namespace
      @namespace = @namespace.to_sym
      node[@namespace] ||= {}
      node_hash = node[@namespace]
    end
    node_hash[key] = value unless node_hash.has_key?(key)
  end
end
