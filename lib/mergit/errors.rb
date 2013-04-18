class Mergit
  # The superclass for all errors raised by {Mergit}
  class MergitError < StandardError; end

  # This is raised whenever a required library isn't found.
  class RequirementNotFound < MergitError; end
end

