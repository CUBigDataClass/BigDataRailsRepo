class Hash

	def method_missing(method, *args, &block)
		if (the_key = self.keys.detect{ |k| k.to_s == method.to_s } )
			return self[the_key]
		else
			super method, *args, &block
		end
	end

end
