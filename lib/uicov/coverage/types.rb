#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CoverageDataType
    COVERAGE = :COVERAGE  # Gathered coverage
    TEMPLATE = :TEMPLATE  # Coverage template
    FULL = :FULL          # Merged template and coverage data
    UNKNOWN = :UNKNOWN    # Unknown (set by default)
  end
end

