module Render
  module_function

  def render(template, *hashables)
    hashables.each do |hashable|
      next if hashable.respond_to?(:to_h)

      raise NotImplementedError, "Object can not be coerced into a Hash: #{hashable}"
    end

    Rendered.new(
      {}.merge(
        *hashables.map(&:to_h)
      )
    )._render(template)
  end

  class Rendered < OpenStruct
    def _render(template)
      ERB.new(template, trim_mode: '-', eoutvar: '_erbout').result(binding)
    rescue StandardError => e
      raise Error, "Render error: #{e.message}"
    end
  end

  private_constant :Rendered
end
